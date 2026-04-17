// Vercel Serverless Function — /api/chat
// Multi-agent orchestration with OpenAI, Anthropic, DeepSeek

const AGENT_DEFINITIONS = {
  analyst: {
    name: 'Analyst',
    system: 'Du bist ein analytischer KI-Agent. Zerlege die Aufgabe in Kernkomponenten, identifiziere Anforderungen und strukturiere das Problem klar. Antworte auf Deutsch, kurz und präzise (max 2 Sätze).'
  },
  researcher: {
    name: 'Researcher',
    system: 'Du bist ein Recherche-Agent. Sammle relevante Fakten, Daten und Best Practices zum Thema. Antworte auf Deutsch, kurz und präzise (max 2 Sätze).'
  },
  creative: {
    name: 'Creative',
    system: 'Du bist ein kreativer KI-Agent. Entwickle alternative Perspektiven und unkonventionelle Lösungsansätze. Antworte auf Deutsch, kurz und präzise (max 2 Sätze).'
  },
  critic: {
    name: 'Critic',
    system: 'Du bist ein kritischer Prüf-Agent. Hinterfrage Ansätze, finde Schwachstellen und Verbesserungspotenzial. Antworte auf Deutsch, kurz und präzise (max 2 Sätze).'
  },
  synthesizer: {
    name: 'Synthesizer',
    system: 'Du bist der Synthesizer-Agent von Orka AI. Du erhältst die Analysen mehrerer Agenten und erstellst daraus eine finale, hochwertige Antwort. Antworte ausführlich, gut strukturiert mit Markdown (Überschriften, Listen, Fettdruck). Antworte auf Deutsch.'
  },
  judge: {
    name: 'Quality Judge',
    system: 'Du bist der Qualitäts-Agent. Bewerte die Antwort auf einer Skala von 1-10. Wenn unter 8, nenne konkrete Verbesserungen. Antworte auf Deutsch, kurz (max 2 Sätze).'
  }
};

const MODE_PIPELINES = {
  fast: ['analyst', 'synthesizer'],
  smart: ['analyst', 'researcher', 'creative', 'critic', 'synthesizer'],
  deep: ['analyst', 'researcher', 'creative', 'critic', 'synthesizer', 'judge']
};

const MODE_MODELS = {
  fast: { provider: 'deepseek', model: 'deepseek-chat' },
  smart: { provider: 'openai', model: 'gpt-4o' },
  deep: { provider: 'anthropic', model: 'claude-sonnet-4-20250514' }
};

// ── Provider call functions ──

async function callOpenAI(messages, model) {
  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
    },
    body: JSON.stringify({
      model,
      messages,
      max_tokens: 4096,
      temperature: 0.7
    })
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
      model,
      max_tokens: 4096,
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
    body: JSON.stringify({
      model,
      messages,
      max_tokens: 4096,
      temperature: 0.7
    })
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

// ── Main handler ──

export default async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { message, mode = 'smart', history = [] } = req.body;

    if (!message || typeof message !== 'string' || message.length > 10000) {
      return res.status(400).json({ error: 'Invalid message' });
    }

    const validModes = ['fast', 'smart', 'deep'];
    const safeMode = validModes.includes(mode) ? mode : 'smart';

    const pipeline = MODE_PIPELINES[safeMode];
    const { provider, model } = MODE_MODELS[safeMode];
    const reasoning = [];

    // Build conversation history (last 10 messages max)
    const recentHistory = history.slice(-10).map(m => ({
      role: m.role === 'user' ? 'user' : 'assistant',
      content: m.content
    }));

    // Run pre-synthesis agents
    let agentContext = '';
    for (const agentId of pipeline) {
      if (agentId === 'synthesizer') continue;

      const agent = AGENT_DEFINITIONS[agentId];
      const agentMessages = [
        { role: 'system', content: agent.system },
        ...recentHistory,
        { role: 'user', content: message }
      ];

      const summary = await callLLM(provider, model, agentMessages);
      agentContext += `\n[${agent.name}]: ${summary}`;
      reasoning.push({
        agent: agentId,
        name: agent.name,
        summary: summary.substring(0, 200)
      });
    }

    // Synthesizer gets all agent outputs
    const synthAgent = AGENT_DEFINITIONS.synthesizer;
    const synthMessages = [
      { role: 'system', content: synthAgent.system },
      ...recentHistory,
      {
        role: 'user',
        content: `Benutzeranfrage: ${message}\n\nAgenten-Analysen:${agentContext}\n\nErstelle basierend auf allen Agenten-Analysen eine hochwertige, strukturierte Antwort.`
      }
    ];

    const response = await callLLM(provider, model, synthMessages);

    // Deep mode: Judge can request refinement
    if (safeMode === 'deep' && pipeline.includes('judge')) {
      const judgeAgent = AGENT_DEFINITIONS.judge;
      const judgeMessages = [
        { role: 'system', content: judgeAgent.system },
        { role: 'user', content: `Bewerte diese Antwort:\n\n${response}` }
      ];
      const judgment = await callLLM(provider, model, judgeMessages);
      reasoning.push({
        agent: 'judge',
        name: 'Quality Judge',
        summary: judgment.substring(0, 200)
      });
    }

    return res.status(200).json({ response, reasoning });

  } catch (error) {
    console.error('Chat API error:', error);
    return res.status(500).json({
      error: 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.',
      detail: process.env.APP_DEBUG === 'true' ? error.message : undefined
    });
  }
}
