// Vercel Serverless Function — /api/research
// Deep web research with multi-agent pipeline
// Agents: Analyst → Web-Researcher → Verifier → Synthesizer

// ── Provider call functions ──

async function callOpenAI(messages, model) {
  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
    },
    body: JSON.stringify({ model, messages, max_tokens: 4096, temperature: 0.4 })
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`OpenAI error ${res.status}: ${err}`);
  }
  const data = await res.json();
  return data.choices[0].message.content;
}

async function callAnthropic(messages, model) {
  const systemMsg = messages.find(m => m.role === 'system');
  const userMsgs = messages.filter(m => m.role !== 'system');
  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': process.env.ANTHROPIC_API_KEY,
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify({
      model, max_tokens: 4096,
      system: systemMsg ? systemMsg.content : '',
      messages: userMsgs.map(m => ({ role: m.role, content: m.content }))
    })
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Anthropic error ${res.status}: ${err}`);
  }
  const data = await res.json();
  return data.content[0].text;
}

async function callDeepSeek(messages, model) {
  const res = await fetch('https://api.deepseek.com/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`
    },
    body: JSON.stringify({ model, messages, max_tokens: 2048, temperature: 0.3 })
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`DeepSeek error ${res.status}: ${err}`);
  }
  const data = await res.json();
  return data.choices[0].message.content;
}

async function callLLM(provider, model, messages) {
  if (provider === 'openai') return callOpenAI(messages, model);
  if (provider === 'anthropic') return callAnthropic(messages, model);
  if (provider === 'deepseek') return callDeepSeek(messages, model);
  throw new Error(`Unknown provider: ${provider}`);
}

// ── Web Search Providers ──

async function searchBrave(queries) {
  const key = process.env.BRAVE_SEARCH_API_KEY;
  if (!key) return null;

  const allResults = [];
  for (const query of queries.slice(0, 3)) {
    try {
      const res = await fetch(
        `https://api.search.brave.com/res/v1/web/search?q=${encodeURIComponent(query)}&count=5&search_lang=de`,
        { headers: { 'Accept': 'application/json', 'Accept-Encoding': 'gzip', 'X-Subscription-Token': key } }
      );
      if (res.ok) {
        const data = await res.json();
        if (data.web && data.web.results) {
          allResults.push(...data.web.results.map(r => ({
            title: r.title,
            url: r.url,
            snippet: r.description || '',
            age: r.age || '',
            domain: (() => { try { return new URL(r.url).hostname.replace('www.', ''); } catch { return ''; } })()
          })));
        }
      }
    } catch (e) { /* skip failed query */ }
  }
  const seen = new Set();
  return allResults.filter(r => {
    if (seen.has(r.url)) return false;
    seen.add(r.url);
    return true;
  }).slice(0, 10);
}

async function searchPerplexity(message, history) {
  const key = process.env.PERPLEXITY_API_KEY;
  if (!key) return null;

  const messages = [
    { role: 'system', content: 'Du bist ein präziser Recherche-Assistent. Recherchiere gründlich im Web und antworte faktenbasiert auf Deutsch. Nenne immer die Quellen.' },
    ...history.slice(-6).map(m => ({ role: m.role === 'user' ? 'user' : 'assistant', content: m.content })),
    { role: 'user', content: message }
  ];

  try {
    const res = await fetch('https://api.perplexity.ai/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${key}` },
      body: JSON.stringify({ model: 'sonar-pro', messages, max_tokens: 4096, temperature: 0.2 })
    });
    if (!res.ok) return null;
    const data = await res.json();
    return {
      content: data.choices[0].message.content,
      citations: data.citations || []
    };
  } catch { return null; }
}

// ── Main Handler ──

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { message, history = [] } = req.body;

    if (!message || typeof message !== 'string' || message.length > 10000) {
      return res.status(400).json({ error: 'Invalid message' });
    }

    const reasoning = [];
    const sources = [];

    // ── Step 1: Analyst — Extract search queries (DeepSeek, fast & cheap) ──
    const queryExtraction = await callLLM('deepseek', 'deepseek-chat', [
      { role: 'system', content: 'Du bist ein Such-Analyst. Extrahiere aus der Benutzerfrage 2-3 präzise Suchbegriffe für eine Websuche. Gib NUR die Suchbegriffe zurück, einen pro Zeile. Keine Erklärungen.' },
      { role: 'user', content: message }
    ]);

    const searchQueries = queryExtraction.split('\n')
      .map(q => q.replace(/^[\d\.\-\*]+\s*/, '').trim())
      .filter(q => q.length > 2)
      .slice(0, 3);

    reasoning.push({
      agent: 'analyst',
      name: 'Analyst',
      summary: 'Suchbegriffe: ' + searchQueries.join(' | ')
    });

    // ── Step 2: Web-Researcher — Search the web ──
    let searchResults = null;
    let perplexityResult = null;
    let searchProvider = 'none';

    // Try Perplexity first (integrated search + synthesis)
    if (process.env.PERPLEXITY_API_KEY) {
      perplexityResult = await searchPerplexity(message, history);
      if (perplexityResult) {
        searchProvider = 'perplexity';
        perplexityResult.citations.forEach((url, i) => {
          let domain = '';
          try { domain = new URL(url).hostname.replace('www.', ''); } catch {}
          sources.push({ title: domain || `Quelle ${i + 1}`, url, snippet: '', domain });
        });
        reasoning.push({
          agent: 'researcher',
          name: 'Web-Researcher',
          summary: `${sources.length} Quellen via Perplexity analysiert.`
        });
      }
    }

    // Fallback: Brave Search
    if (!perplexityResult && process.env.BRAVE_SEARCH_API_KEY) {
      searchResults = await searchBrave(searchQueries);
      if (searchResults && searchResults.length > 0) {
        searchProvider = 'brave';
        sources.push(...searchResults);
        reasoning.push({
          agent: 'researcher',
          name: 'Web-Researcher',
          summary: `${searchResults.length} Webseiten via Brave Search durchsucht.`
        });
      }
    }

    // No search API available
    if (searchProvider === 'none') {
      reasoning.push({
        agent: 'researcher',
        name: 'Web-Researcher',
        summary: 'Kein Suchdienst konfiguriert — nutze KI-Wissen.'
      });
    }

    // ── Step 3: Verifier — Cross-check facts ──
    let verification = '';
    if (searchProvider === 'perplexity') {
      verification = await callLLM('openai', 'gpt-4o', [
        { role: 'system', content: 'Du bist ein Faktenprüfer. Prüfe die Recherche-Ergebnisse auf Konsistenz, Aktualität und mögliche Fehler. Antworte in max 3 Sätzen: was ist verlässlich, was unsicher.' },
        { role: 'user', content: `Frage: "${message}"\n\nRecherche-Ergebnis:\n${perplexityResult.content}` }
      ]);
    } else if (searchProvider === 'brave' && searchResults.length > 0) {
      const ctx = searchResults.map((r, i) => `[${i + 1}] ${r.title}\n${r.url}\n${r.snippet}`).join('\n\n');
      verification = await callLLM('openai', 'gpt-4o', [
        { role: 'system', content: 'Du bist ein Faktenprüfer. Analysiere die Suchergebnisse und identifiziere die verlässlichsten Informationen. Markiere widersprüchliche oder unsichere Punkte. Max 3 Sätze.' },
        { role: 'user', content: `Frage: "${message}"\n\nSuchergebnisse:\n${ctx}` }
      ]);
    } else {
      verification = 'Keine Web-Quellen verfügbar. Antwort basiert auf Trainingsdaten.';
    }

    reasoning.push({
      agent: 'verifier',
      name: 'Verifizierer',
      summary: verification.substring(0, 200)
    });

    // ── Step 4: Synthesizer — Create polished, cited response ──
    let response;
    const recentHistory = history.slice(-6).map(m => ({
      role: m.role === 'user' ? 'user' : 'assistant',
      content: m.content
    }));

    if (searchProvider === 'perplexity') {
      const synthMessages = [
        { role: 'system', content: `Du bist der Synthesizer von Orka AI. Erstelle eine hochwertige, quellenbasierte Antwort auf Deutsch.

Regeln:
- Verwende [1], [2] etc. als Quellenverweise (entsprechen den Quellen in der Recherche)
- Strukturiere klar mit Markdown (Überschriften, Listen, Fettdruck)
- Beginne NICHT mit "Basierend auf meiner Recherche" oder ähnlichem
- Sei direkt, präzise und informativ
- Wenn die Verifizierung Unsicherheiten nennt, kennzeichne diese transparent` },
        ...recentHistory,
        { role: 'user', content: `Frage: ${message}\n\nWeb-Recherche:\n${perplexityResult.content}\n\nVerifizierung: ${verification}\n\nErstelle eine polierte, faktenbasierte Antwort.` }
      ];
      response = await callLLM('anthropic', 'claude-sonnet-4-20250514', synthMessages);
    } else if (searchProvider === 'brave') {
      const searchContext = searchResults.map((r, i) => `[${i + 1}] ${r.title} (${r.domain})\n${r.snippet}`).join('\n\n');
      const synthMessages = [
        { role: 'system', content: `Du bist der Synthesizer von Orka AI. Erstelle eine hochwertige, quellenbasierte Antwort auf Deutsch.

Regeln:
- Verwende [1], [2] etc. als Quellenverweise auf die nummerierten Suchergebnisse
- Strukturiere klar mit Markdown
- Sei direkt, präzise und informativ
- Kennzeichne unsichere Informationen transparent` },
        ...recentHistory,
        { role: 'user', content: `Frage: ${message}\n\nWeb-Suchergebnisse:\n${searchContext}\n\nVerifizierung: ${verification}\n\nErstelle eine polierte, quellenbasierte Antwort.` }
      ];
      response = await callLLM('anthropic', 'claude-sonnet-4-20250514', synthMessages);
    } else {
      // Fallback: LLM knowledge only
      const synthMessages = [
        { role: 'system', content: `Du bist der Recherche-Assistent von Orka AI. Beantworte die Frage gründlich auf Deutsch mit Markdown-Formatierung. Da keine Live-Websuche verfügbar ist, basiert die Antwort auf Trainingsdaten. Weise am Ende kurz darauf hin.` },
        ...recentHistory,
        { role: 'user', content: message }
      ];
      response = await callLLM('openai', 'gpt-4o', synthMessages);
    }

    reasoning.push({
      agent: 'synthesizer',
      name: 'Synthesizer',
      summary: 'Quellenbasierte Antwort erstellt.'
    });

    return res.status(200).json({ response, sources, reasoning });

  } catch (error) {
    console.error('Research API error:', error);
    return res.status(500).json({
      error: 'Recherche-Fehler. Bitte versuche es erneut.',
      detail: process.env.APP_DEBUG === 'true' ? error.message : undefined
    });
  }
}
