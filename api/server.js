import express from 'express';
import cors from 'cors';
import Anthropic from '@anthropic-ai/sdk';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const supabase = createClient(
  process.env.https://mxtpqdlgamotnjefimke.supabase.co,
  process.env.sb_publishable_Q8yTNyXOlv0oMdB8gPh_HQ_HUX05c_l
);

const anthropic = new Anthropic({ apiKey: process.env.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 });

const RAGHAV_CONTEXT = `
You are the AI brain of Raghav's personal second brain system.

About Raghav:
- 25-year-old Product Manager in Mumbai, relocating to Delhi soon
- Just received a job offer from PolicyBazaar; also interviewing at Feeding India (Zomato)
- Currently wrapping up job at current company (leaving end of March/April 2026)
- Building VibeCon 2026 hackathon project — an AI second brain
- Partner: Prerna (long-distance, visits Mumbai/they visit each other)
- Into: cycling, running, triathlon (training for Hyrox Delhi+Mumbai, Aug 2026)
- Side project: automation board for Papa's business
- Helping Madhavbhaiya lose 5kg

Life Areas (A–J):
A=Health&Wellness (A.1 Exercise, A.2 Food, A.3 Sleep, A.4 Mental Health)
B=Personal Growth (B.1 Reading, B.2 Courses, B.3 Skills, B.4 Projects, B.5 Job)
C=Relationships (C.1 Family, C.2 Piri/Prerna, C.3 Friends, C.4 Networking)
D=Money (D.1 Budgeting, D.2 Investments, D.3 Savings, D.4 Debt)
E=Home&Daily Life (E.1 Home Maintenance, E.2 Organization, E.3 Shopping, E.4 Household)
F=Fitness (F.1 Poker, F.2 Ironman/Triathlon, F.3 Geopolitics, F.4 Animal Cruelty, F.5 Docs)
G=Travel&Adventure (G.1 Trip Planning, G.2 Places to Visit, G.3 Travel Docs)
H=Spirituality (H.1 Meditation, H.2 Spiritual Practices)
I=Technology (I.1 Device Mgmt, I.2 Apps & Software)
J=Purpose&Vision (J.1 Long-Term Goals, J.2 Personal Mission)

Priority system (Eisenhower):
1. Urgent/Important  → do immediately
2. Important/Plan    → schedule and protect time
3. Urgent/Delegate   → delegate or batch
4. Eliminate/Minimize → eliminate or ignore
`;

async function organise(rawText, existingActions = [], areaHints = []) {
  const existingNames = existingActions.map(a => a.name).join('\n- ');

  const prompt = `${RAGHAV_CONTEXT}

Raw input from Raghav: "${rawText}"
Area hints (if any): ${areaHints.join(', ') || 'none'}

Existing actions (check for duplicates — if input matches one, return it in "updates" not "new_actions"):
${existingNames ? '- ' + existingNames : 'none yet'}

Analyse the input and return ONLY valid JSON (no markdown):
{
  "new_actions": [
    {
      "name": "specific next physical action (verb + object)",
      "priority": "1. Urgent/Important | 2. Important/Plan | 3. Urgent/Delegate | 4. Eliminate/Minimize",
      "area_code": "exact area code like A.1, B.4, C.2, D.1, G.1",
      "due_date": "YYYY-MM-DD or null",
      "project_hint": "project name this belongs to or null"
    }
  ],
  "updates": [
    {
      "existing_name": "name of existing action to update",
      "note": "what changed or was added"
    }
  ],
  "insight": "1-2 sentence pattern or observation from this input",
  "insight_domain": "area code e.g. A.1, B.5, C.2"
}

Rules:
- Extract 2-4 concrete, specific, physical actions
- Never duplicate an existing action — merge into "updates" instead
- due_date must be YYYY-MM-DD or null
- area_code must match exactly from the A–J system
`;

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1000,
    messages: [{ role: 'user', content: prompt }],
  });

  const raw = response.content.map(c => c.text || '').join('');
  return JSON.parse(raw.replace(/```json|```/g, '').trim());
}

async function processJournal(title, body) {
  const prompt = `${RAGHAV_CONTEXT}

Journal entry titled "${title}":
${body}

Analyse this journal entry and return ONLY valid JSON (no markdown):
{
  "summary": "3 sentence summary of the day",
  "mood": "single phrase describing emotional state",
  "action_items": ["specific action extracted from journal"],
  "area_codes": ["relevant area codes like A.1, B.5"],
  "insight": "1-2 sentence pattern observation from this entry"
}
`;

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 800,
    messages: [{ role: 'user', content: prompt }],
  });

  const raw = response.content.map(c => c.text || '').join('');
  return JSON.parse(raw.replace(/```json|```/g, '').trim());
}

async function generateDailyBrief(actions, projects, recentInsights) {
  const urgentActions = actions
    .filter(a => a.priority === '1. Urgent/Important' && a.status !== 'Done')
    .map(a => `- ${a.name} (${a.area_code}, due ${a.due_date || 'no date'})`)
    .join('\n');

  const activeProjects = projects
    .filter(p => p.status === 'In Progress')
    .map(p => `- ${p.name}: ${p.completion_level}% complete, due ${p.due_date}`)
    .join('\n');

  const prompt = `${RAGHAV_CONTEXT}

Today's urgent actions:
${urgentActions || 'none'}

Active projects:
${activeProjects || 'none'}

Recent insights:
${recentInsights.slice(0, 3).map(i => '- ' + i.text).join('\n') || 'none'}

Generate Raghav's daily brief. Return ONLY valid JSON:
{
  "top3": ["most important thing to do today", "second", "third"],
  "focus_area": "which life area deserves most attention today and why (1 sentence)",
  "energy_note": "honest 1-sentence note about what the data says about Raghav's current state",
  "quick_win": "one small thing Raghav can do in under 10 minutes to build momentum"
}
`;

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 600,
    messages: [{ role: 'user', content: prompt }],
  });

  const raw = response.content.map(c => c.text || '').join('');
  return JSON.parse(raw.replace(/```json|```/g, '').trim());
}

// ROUTES
app.post('/capture', async (req, res) => {
  try {
    const { text, area_hints = [] } = req.body;
    if (!text?.trim()) return res.status(400).json({ error: 'text is required' });

    const { data: capture } = await supabase
      .from('captures')
      .insert({ raw_text: text, area_hints, source: 'manual' })
      .select()
      .single();

    const { data: existingActions } = await supabase
      .from('actions')
      .select('id, name, status')
      .neq('status', 'Done')
      .limit(50);

    const organised = await organise(text, existingActions || [], area_hints);

    const newActionIds = [];

    if (organised.new_actions?.length) {
      const projectIds = {};
      for (const a of organised.new_actions) {
        if (a.project_hint) {
          const { data: proj } = await supabase
            .from('projects')
            .select('id, name')
            .ilike('name', `%${a.project_hint}%`)
            .single();
          if (proj) projectIds[a.project_hint] = proj.id;
        }
      }

      const toInsert = organised.new_actions.map(a => ({
        name: a.name,
        priority: a.priority,
        area_code: a.area_code,
        due_date: a.due_date || null,
        project_id: a.project_hint ? projectIds[a.project_hint] || null : null,
        source: 'capture',
        status: 'Not Started',
      }));

      const { data: inserted } = await supabase
        .from('actions')
        .insert(toInsert)
        .select();

      if (inserted) newActionIds.push(...inserted.map(a => a.id));
    }

    let savedInsight = null;
    if (organised.insight) {
      const { data: ins } = await supabase
        .from('insights')
        .insert({
          text: organised.insight,
          area_code: organised.insight_domain,
          domain: organised.insight_domain,
          source_capture_ids: [capture.id],
        })
        .select()
        .single();
      savedInsight = ins;
    }

    await supabase
      .from('captures')
      .update({ processed: true, result_action_ids: newActionIds, result_insight: organised.insight })
      .eq('id', capture.id);

    res.json({
      capture_id: capture.id,
      new_actions: organised.new_actions || [],
      updates: organised.updates || [],
      insight: organised.insight,
      insight_domain: organised.insight_domain,
    });
  } catch (err) {
    console.error('/capture error:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/actions', async (req, res) => {
  try {
    const { status, area_code } = req.query;
    let query = supabase
      .from('actions')
      .select('*, projects(name)')
      .order('priority', { ascending: true })
      .order('due_date', { ascending: true, nullsFirst: false });

    if (status) query = query.eq('status', status);
    if (area_code) query = query.eq('area_code', area_code);

    const { data, error } = await query;
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/actions/:id', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('actions')
      .update({ ...req.body, updated_at: new Date().toISOString() })
      .eq('id', req.params.id)
      .select()
      .single();
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/projects', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .order('priority', { ascending: true })
      .order('due_date', { ascending: true, nullsFirst: false });
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/projects/:id', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('projects')
      .update({ ...req.body, updated_at: new Date().toISOString() })
      .eq('id', req.params.id)
      .select()
      .single();
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/journal', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('journal_entries')
      .select('*')
      .order('entry_date', { ascending: false });
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/journal', async (req, res) => {
  try {
    const { title, body, entry_date } = req.body;
    if (!title || !body) return res.status(400).json({ error: 'title and body required' });

    const processed = await processJournal(title, body);

    const { data: entry, error } = await supabase
      .from('journal_entries')
      .insert({
        title,
        body,
        entry_date: entry_date || new Date().toISOString().split('T')[0],
        summary: processed.summary,
        mood: processed.mood,
        tags: [],
        area_codes: processed.area_codes || [],
        action_items: processed.action_items || [],
        source: 'manual',
      })
      .select()
      .single();
    if (error) throw error;

    const createdActions = [];
    if (processed.action_items?.length) {
      for (const item of processed.action_items) {
        const organised = await organise(item, [], processed.area_codes || []);
        if (organised.new_actions?.length) {
          const { data: act } = await supabase
            .from('actions')
            .insert({
              name: organised.new_actions[0].name,
              priority: organised.new_actions[0].priority,
              area_code: organised.new_actions[0].area_code,
              due_date: organised.new_actions[0].due_date || null,
              source: 'journal',
              status: 'Not Started',
            })
            .select()
            .single();
          if (act) createdActions.push(act);
        }
      }
    }

    if (processed.insight) {
      await supabase.from('insights').insert({
        text: processed.insight,
        area_code: processed.area_codes?.[0],
        domain: processed.area_codes?.[0],
      });
    }

    res.json({ entry, created_actions: createdActions, processed });
  } catch (err) {
    console.error('/journal error:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/insights', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('insights')
      .select('*')
      .order('created_at', { ascending: false });
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/resources', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('resources')
      .select('*')
      .order('created_at', { ascending: false });
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/resources', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('resources')
      .insert(req.body)
      .select()
      .single();
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/areas', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('areas')
      .select('*')
      .order('code', { ascending: true });
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/budget', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('budget_entries')
      .select('*, projects(name)')
      .order('entry_date', { ascending: false });
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/budget', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('budget_entries')
      .insert(req.body)
      .select()
      .single();
    if (error) throw error;
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/dashboard', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];

    const [actionsRes, projectsRes, insightsRes, journalRes, budgetRes] = await Promise.all([
      supabase.from('actions').select('*').neq('status', 'Done').order('priority').order('due_date', { nullsFirst: false }),
      supabase.from('projects').select('*').neq('status', 'Archived').order('priority').order('due_date', { nullsFirst: false }),
      supabase.from('insights').select('*').order('created_at', { ascending: false }).limit(5),
      supabase.from('journal_entries').select('id, title, entry_date, mood, summary').order('entry_date', { ascending: false }).limit(5),
      supabase.from('budget_entries').select('amount').gte('entry_date', today.slice(0, 7) + '-01'),
    ]);

    const actions = actionsRes.data || [];
    const projects = projectsRes.data || [];
    const insights = insightsRes.data || [];

    const overdue = actions.filter(a => a.due_date && a.due_date < today);
    const totalBudget = (budgetRes.data || []).reduce((s, b) => s + Number(b.amount), 0);
    const done = actions.filter(a => a.status === 'Done').length;
    const momentum = actions.length > 0 ? (done / (done + actions.length)).toFixed(2) : '0.00';

    let brief = null;
    try {
      brief = await generateDailyBrief(actions, projects, insights);
    } catch (e) {
      console.error('brief gen failed:', e.message);
    }

    res.json({
      stats: {
        actions_pending: actions.length,
        actions_overdue: overdue.length,
        projects_active: projects.filter(p => p.status === 'In Progress').length,
        momentum,
        month_spend: totalBudget,
      },
      actions: actions.slice(0, 10),
      projects: projects.slice(0, 10),
      insights: insights.slice(0, 3),
      recent_journal: journalRes.data || [],
      brief,
    });
  } catch (err) {
    console.error('/dashboard error:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (_, res) => res.json({ status: 'ok', version: '1.0.0' }));

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Vibe-Mind API running on :${PORT}`));
