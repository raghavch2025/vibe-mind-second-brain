import express from 'express';
import cors from 'cors';
import Anthropic from '@anthropic-ai/sdk';
import { createClient } from '@supabase/supabase-js';

const app = express();
app.use(cors());
app.use(express.json());

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// Health check
app.get('/health', (_, res) => res.json({ status: 'ok', version: '1.0.0' }));

// Dashboard
app.get('/dashboard', async (req, res) => {
  try {
    const { data: actions } = await supabase.from('actions').select('*');
    const { data: projects } = await supabase.from('projects').select('*');
    res.json({ actions: actions || [], projects: projects || [] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Actions
app.get('/actions', async (req, res) => {
  try {
    const { data } = await supabase.from('actions').select('*');
    res.json(data || []);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Capture
app.post('/capture', async (req, res) => {
  try {
    const { text } = req.body;
    if (!text) return res.status(400).json({ error: 'text required' });
    const { data: capture } = await supabase.from('captures').insert({ raw_text: text, source: 'manual' }).select().single();
    res.json({ capture_id: capture.id, message: 'Captured' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default app;
