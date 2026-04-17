// Vercel Serverless Function — /api/analyze
// Image & Video analysis via OpenAI Vision + Anthropic Vision

const MODE_MODELS = {
  fast: { provider: 'openai', model: 'gpt-4o-mini' },
  smart: { provider: 'openai', model: 'gpt-4o' },
  deep: { provider: 'anthropic', model: 'claude-sonnet-4-20250514' }
};

async function analyzeWithOpenAI(images, message, model) {
  const content = [{ type: 'text', text: message }];
  for (const img of images) {
    content.push({
      type: 'image_url',
      image_url: { url: img.data, detail: model === 'gpt-4o-mini' ? 'low' : 'auto' }
    });
  }

  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
    },
    body: JSON.stringify({
      model,
      messages: [
        { role: 'system', content: 'Du bist ein visueller Analyse-Agent von Orka AI. Analysiere Bilder detailliert, strukturiert und auf Deutsch. Nutze Markdown.' },
        { role: 'user', content }
      ],
      max_tokens: 4096,
      temperature: 0.4
    })
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`OpenAI Vision error ${res.status}: ${err}`);
  }
  const data = await res.json();
  return data.choices[0].message.content;
}

async function analyzeWithAnthropic(images, message, model) {
  const content = [];
  for (const img of images) {
    // Extract base64 and media type from data URL
    const match = img.data.match(/^data:(image\/\w+);base64,(.+)$/);
    if (match) {
      content.push({
        type: 'image',
        source: { type: 'base64', media_type: match[1], data: match[2] }
      });
    }
  }
  content.push({ type: 'text', text: message });

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
      system: 'Du bist ein visueller Analyse-Agent von Orka AI. Analysiere Bilder detailliert, strukturiert und auf Deutsch. Nutze Markdown.',
      messages: [{ role: 'user', content }]
    })
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Anthropic Vision error ${res.status}: ${err}`);
  }
  const data = await res.json();
  return data.content[0].text;
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { type, images = [], message, mode = 'smart' } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({ error: 'Nachricht fehlt.' });
    }

    // Validate images — limit to 4, max ~10MB per image after base64
    const safeImages = images.slice(0, 4).filter(img =>
      img.data && typeof img.data === 'string' && img.data.startsWith('data:image/')
    );

    if (type === 'image' && safeImages.length === 0) {
      // Fall back to text-only analysis if no valid images
      return res.status(400).json({ error: 'Keine gültigen Bilder empfangen.' });
    }

    const validModes = ['fast', 'smart', 'deep'];
    const safeMode = validModes.includes(mode) ? mode : 'smart';
    const { provider, model } = MODE_MODELS[safeMode];

    let response;
    if (provider === 'anthropic') {
      response = await analyzeWithAnthropic(safeImages, message, model);
    } else {
      response = await analyzeWithOpenAI(safeImages, message, model);
    }

    return res.status(200).json({
      response,
      reasoning: [
        { agent: 'vision', name: 'Vision-Analyse', summary: `${safeImages.length} Bild(er) mit ${model} analysiert.` }
      ]
    });

  } catch (error) {
    console.error('Analyze API error:', error);
    return res.status(500).json({
      error: 'Analyse fehlgeschlagen. Bitte versuche es erneut.',
      detail: process.env.APP_DEBUG === 'true' ? error.message : undefined
    });
  }
}
