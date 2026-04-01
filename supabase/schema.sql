-- ============================================================
-- VIBE-MIND: Complete Database
-- Paste this entire file into Supabase SQL Editor → Run
-- ============================================================

-- ── TABLES ───────────────────────────────────────────────────

CREATE TABLE areas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  parent_code TEXT,
  icon TEXT,
  scope TEXT DEFAULT 'Personal',
  status TEXT DEFAULT 'Active',
  typology TEXT DEFAULT 'Areas',
  quick_access TEXT DEFAULT 'Unpinned',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  status TEXT DEFAULT 'Not Started',
  priority TEXT DEFAULT '2. Important/Plan',
  due_date DATE,
  area_codes TEXT[],
  completion_level INTEGER DEFAULT 0 CHECK (completion_level BETWEEN 0 AND 100),
  scope TEXT DEFAULT 'Personal',
  url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  status TEXT DEFAULT 'Not Started',
  priority TEXT DEFAULT '2. Important/Plan',
  due_date DATE,
  area_code TEXT,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  url TEXT,
  source TEXT DEFAULT 'manual',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  status TEXT DEFAULT 'Not Started',
  priority TEXT DEFAULT '2. Important/Plan',
  due_date DATE,
  area_codes TEXT[],
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  related_task_ids UUID[],
  url TEXT,
  source TEXT DEFAULT 'manual',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  entry_date DATE DEFAULT CURRENT_DATE,
  body TEXT,
  summary TEXT,
  mood TEXT,
  tags TEXT[],
  area_codes TEXT[],
  action_items TEXT[],
  source TEXT DEFAULT 'manual',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  resource_type TEXT DEFAULT 'Resource',
  topic TEXT,
  author_source TEXT,
  url TEXT,
  area_codes TEXT[],
  status TEXT DEFAULT 'Not Started',
  quick_access TEXT DEFAULT 'Unpinned',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE captures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  raw_text TEXT NOT NULL,
  processed BOOLEAN DEFAULT FALSE,
  source TEXT DEFAULT 'manual',
  area_hints TEXT[],
  result_action_ids UUID[],
  result_insight TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  domain TEXT,
  area_code TEXT,
  source_capture_ids UUID[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE budget_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  area_code TEXT,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  entry_date DATE DEFAULT CURRENT_DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── INDEXES ──────────────────────────────────────────────────

CREATE INDEX idx_actions_status   ON actions(status);
CREATE INDEX idx_actions_priority ON actions(priority);
CREATE INDEX idx_actions_due      ON actions(due_date);
CREATE INDEX idx_projects_status  ON projects(status);
CREATE INDEX idx_journal_date     ON journal_entries(entry_date DESC);
CREATE INDEX idx_captures_proc    ON captures(processed);

-- ── ROW LEVEL SECURITY ────────────────────────────────────────

ALTER TABLE areas            ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects         ENABLE ROW LEVEL SECURITY;
ALTER TABLE actions          ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks            ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries  ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources        ENABLE ROW LEVEL SECURITY;
ALTER TABLE captures         ENABLE ROW LEVEL SECURITY;
ALTER TABLE insights         ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_entries   ENABLE ROW LEVEL SECURITY;

-- Allow service_role key full access (used by backend)
CREATE POLICY "Service full access" ON areas           FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service full access" ON projects        FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service full access" ON actions         FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service full access" ON tasks           FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service full access" ON journal_entries FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service full access" ON resources       FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service full access" ON captures        FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service full access" ON insights        FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Service full access" ON budget_entries  FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Also allow anon for now (remove later when you add auth)
CREATE POLICY "Anon full access" ON areas           FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Anon full access" ON projects        FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Anon full access" ON actions         FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Anon full access" ON tasks           FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Anon full access" ON journal_entries FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Anon full access" ON resources       FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Anon full access" ON captures        FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Anon full access" ON insights        FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Anon full access" ON budget_entries  FOR ALL TO anon USING (true) WITH CHECK (true);

-- ── SEED: AREAS A–J ──────────────────────────────────────────

INSERT INTO areas (code, name, parent_code, icon, typology, quick_access) VALUES
  ('A',   'Health & Wellness',         NULL, '🏥', 'Areas',    'Unpinned'),
  ('A.1', 'Exercise',                  'A',  '🏃', 'Subareas', 'Pinned'),
  ('A.2', 'Food',                      'A',  '🥗', 'Subareas', 'Pinned'),
  ('A.3', 'Sleep',                     'A',  '😴', 'Subareas', 'Pinned'),
  ('A.4', 'Mental Health',             'A',  '🧠', 'Subareas', 'Pinned'),
  ('B',   'Personal Growth',           NULL, '🌱', 'Areas',    'Unpinned'),
  ('B.1', 'Reading',                   'B',  '📚', 'Subareas', 'Pinned'),
  ('B.2', 'Courses and Learning',      'B',  '🎓', 'Subareas', 'Pinned'),
  ('B.3', 'Skill Development',         'B',  '🛠', 'Subareas', 'Pinned'),
  ('B.4', 'Projects',                  'B',  '💡', 'Subareas', 'Pinned'),
  ('B.5', 'Job',                       'B',  '💼', 'Subareas', 'Pinned'),
  ('C',   'Relationships',             NULL, '❤', 'Areas',    'Unpinned'),
  ('C.1', 'Family',                    'C',  '👪', 'Subareas', 'Pinned'),
  ('C.2', 'Piri',                      'C',  '💕', 'Subareas', 'Pinned'),
  ('C.3', 'Friends',                   'C',  '👥', 'Subareas', 'Pinned'),
  ('C.4', 'Networking',                'C',  '🤝', 'Subareas', 'Pinned'),
  ('D',   'Money',                     NULL, '💰', 'Areas',    'Unpinned'),
  ('D.1', 'Budgeting',                 'D',  '📊', 'Subareas', 'Pinned'),
  ('D.2', 'Investments',               'D',  '📈', 'Subareas', 'Pinned'),
  ('D.3', 'Savings',                   'D',  '🏦', 'Subareas', 'Pinned'),
  ('D.4', 'Debt',                      'D',  '💳', 'Subareas', 'Pinned'),
  ('E',   'Home & Daily Life',         NULL, '🏠', 'Areas',    'Unpinned'),
  ('E.1', 'Home Maintenance',          'E',  '🔧', 'Subareas', 'Pinned'),
  ('E.2', 'Organization',              'E',  '📦', 'Subareas', 'Pinned'),
  ('E.3', 'Shopping & Supplies',       'E',  '🛒', 'Subareas', 'Pinned'),
  ('E.4', 'Household Tasks',           'E',  '🧹', 'Subareas', 'Pinned'),
  ('F',   'Fitness Influencer',        NULL, '🏋', 'Areas',    'Unpinned'),
  ('F.1', 'Poker Player',              'F',  '🃏', 'Subareas', 'Pinned'),
  ('F.2', 'Ironman',                   'F',  '🏊', 'Subareas', 'Pinned'),
  ('F.3', 'Geopolitics',               'F',  '🌍', 'Subareas', 'Pinned'),
  ('F.4', 'Animal Cruelty',            'F',  '🐾', 'Subareas', 'Pinned'),
  ('F.5', 'Documentaries',             'F',  '🎬', 'Subareas', 'Pinned'),
  ('G',   'Travel & Adventure',        NULL, '✈', 'Areas',    'Unpinned'),
  ('G.1', 'Trip Planning',             'G',  '🗺', 'Subareas', 'Pinned'),
  ('G.2', 'Places to Visit',           'G',  '📍', 'Subareas', 'Pinned'),
  ('G.3', 'Travel Docs',               'G',  '📄', 'Subareas', 'Pinned'),
  ('H',   'Spirituality & Reflection', NULL, '🧘', 'Areas',    'Unpinned'),
  ('H.1', 'Meditation',                'H',  '🕉', 'Subareas', 'Pinned'),
  ('H.2', 'Spiritual Practices',       'H',  '✨', 'Subareas', 'Pinned'),
  ('I',   'Technology & Tools',        NULL, '💻', 'Areas',    'Unpinned'),
  ('I.1', 'Device Management',         'I',  '📱', 'Subareas', 'Pinned'),
  ('I.2', 'Apps & Software',           'I',  '⚙', 'Subareas', 'Pinned'),
  ('J',   'Purpose & Life Vision',     NULL, '🎯', 'Areas',    'Unpinned'),
  ('J.1', 'Long-Term Goals',           'J',  '🔭', 'Subareas', 'Pinned'),
  ('J.2', 'Personal Mission',          'J',  '📜', 'Subareas', 'Pinned');

-- ── SEED: PROJECTS (from your Notion export) ─────────────────

INSERT INTO projects (name, status, priority, due_date, area_codes, completion_level, scope) VALUES
  ('The 2nd brain',                        'In Progress',  '1. Urgent/Important', '2026-04-05', ARRAY['B.4'],        15,  'Business'),
  ('Relocating to Delhi',                  'In Progress',  '1. Urgent/Important', '2026-04-25', ARRAY['E.1'],        20,  'Business'),
  ('Travel to Kolkata',                    'Not Started',  '1. Urgent/Important', '2026-04-11', ARRAY['C.2'],        0,   'Personal'),
  ('Ending Cherry on a good note',         'In Progress',  '2. Important/Plan',   '2026-04-30', ARRAY['B.5'],        20,  'Personal'),
  ('Applying to Product Companies',        'In Progress',  '2. Important/Plan',   '2026-04-30', ARRAY['B'],          20,  'Business'),
  ('Hyrox Delhi+Mumbai',                   'In Progress',  '2. Important/Plan',   '2026-08-20', ARRAY['F.2'],        20,  NULL),
  ('book brain complete',                  'In Progress',  '2. Important/Plan',   '2026-04-05', ARRAY['B.1'],        50,  NULL),
  ('trip to Anjanta alora caves',          'Not Started',  '2. Important/Plan',   '2026-04-30', ARRAY['G'],          50,  'Business'),
  ('Madhav bhaiya weight reduction by 5 kg','Not Started', '2. Important/Plan',   '2026-05-31', ARRAY['C.1'],        1,   NULL),
  ('TVD watching',                         'Not Started',  '2. Important/Plan',   '2026-04-30', ARRAY['C.2'],        0,   NULL),
  ('Parent coming to bombay',              'In Progress',  '2. Important/Plan',   '2026-03-31', ARRAY['C.1'],        100, NULL);

-- ── SEED: ACTIONS (from your Notion Actions DB) ───────────────

INSERT INTO actions (name, status, priority, due_date, area_code, source)
SELECT
  a.name, a.status, a.priority, a.due_date::DATE, a.area_code, 'notion'
FROM (VALUES
  ('Book flight',                     'Not Started', '1. Urgent/Important', '2026-04-08', 'C.2'),
  ('Soumaya tandon appointment',      'Not Started', '1. Urgent/Important', '2026-04-07', 'C.1'),
  ('Tickets for Anjanta Alora caves', 'Not Started', '1. Urgent/Important', '2026-04-01', 'G.1'),
  ('Cleaning the home',               'Not Started', '1. Urgent/Important', '2025-03-13', 'E.1'),
  ('Apply for leave on monday',       'Not Started', '1. Urgent/Important', '2025-03-13', 'C.1'),
  ('Talk with Yogita PB',             'Not Started', '2. Important/Plan',   '2026-04-02', 'B.5'),
  ('1 more Calculator tickets',       'Not Started', '2. Important/Plan',   '2026-04-02', 'B.5'),
  ('Top banner funnel with Deepak',   'In Progress', '2. Important/Plan',   '2026-04-01', 'B.5'),
  ('Working on 2nd brain and closing','Not Started', '2. Important/Plan',   '2026-04-01', 'B.4'),
  ('Vibecon Organisation close',      'Not Started', '2. Important/Plan',   '2025-03-13', 'B.4'),
  ('Cult Strength at 6pm',            'In Progress', '2. Important/Plan',   '2025-03-13', 'A.1')
) AS a(name, status, priority, due_date, area_code);

-- Link actions to projects
UPDATE actions SET project_id = (SELECT id FROM projects WHERE name = 'Travel to Kolkata' LIMIT 1)
  WHERE name = 'Book flight';
UPDATE actions SET project_id = (SELECT id FROM projects WHERE name = 'Madhav bhaiya weight reduction by 5 kg' LIMIT 1)
  WHERE name = 'Soumaya tandon appointment';
UPDATE actions SET project_id = (SELECT id FROM projects WHERE name = 'trip to Anjanta alora caves' LIMIT 1)
  WHERE name = 'Tickets for Anjanta Alora caves';
UPDATE actions SET project_id = (SELECT id FROM projects WHERE name = 'Relocating to Delhi' LIMIT 1)
  WHERE name IN ('Cleaning the home', 'Talk with Yogita PB');
UPDATE actions SET project_id = (SELECT id FROM projects WHERE name = 'Parent coming to bombay' LIMIT 1)
  WHERE name = 'Apply for leave on monday';
UPDATE actions SET project_id = (SELECT id FROM projects WHERE name = 'Ending Cherry on a good note' LIMIT 1)
  WHERE name IN ('1 more Calculator tickets', 'Top banner funnel with Deepak');
UPDATE actions SET project_id = (SELECT id FROM projects WHERE name = 'The 2nd brain' LIMIT 1)
  WHERE name IN ('Working on 2nd brain and closing', 'Vibecon Organisation close');
UPDATE actions SET project_id = (SELECT id FROM projects WHERE name = 'Hyrox Delhi+Mumbai' LIMIT 1)
  WHERE name = 'Cult Strength at 6pm';

-- ── SEED: TASKS (from your Notion Tasks DB) ───────────────────

INSERT INTO tasks (name, status, priority, due_date, area_codes, source) VALUES
  ('Simple Task 2',         'Not Started', '1. Urgent/Important',  '2024-11-18', ARRAY['D.1'], 'notion'),
  ('Simple Task 3',         'Not Started', '1. Urgent/Important',  '2024-11-27', ARRAY[],      'notion'),
  ('Simple Task 4',         'Not Started', '2. Important/Plan',    '2024-11-12', ARRAY[],      'notion'),
  ('Simple Task 5',         'Not Started', '3. Urgent/Delegate',   '2024-11-13', ARRAY['I.1'], 'notion'),
  ('Simple Task Example 6', 'Not Started', '4. Eliminate/Minimize','2024-11-11', ARRAY[],      'notion');

-- ── SEED: JOURNAL ENTRIES (from your Notion journaling) ───────

INSERT INTO journal_entries (title, entry_date, body, summary, mood, area_codes, action_items) VALUES

('The 2nd brain', '2026-03-27',
 'Woke up late after late-night discussion with Rohit about VibeCon 2026 hackathon organized by Emergent, inspired by "Building a Second Brain" book. Built multiple prototypes throughout the day, including while commuting. Informed Apti about resignation; date announced March 31st by Chetan. Not following fitness for 4 days — eating junk and missing exercise. Had video call with Prerna — she was looking really cute.',
 'Productive hackathon day building VibeCon prototypes while handling resignation logistics. Fitness slipping for 4 days due to late nights. Positive mood about the project and relationship.',
 'Positive but guilt about fitness',
 ARRAY['B.4', 'A.1', 'C.2'],
 ARRAY['Go for a run tomorrow to get back on track', 'Continue developing VibeCon prototype']),

('Life log — After a Long Time', '2026-03-25',
 'Back from Lonavala (Galibagh). Sharp neck pain on waking — still went to office, want to leave on a good note. Spent a lot of time on automation board for Papa''s business. It feels good to say I have a small side business now. Rohit from Feeding India called — gave a little hope about a possible opportunity. Not a dramatic day. But life is moving.',
 'Returned from Lonavala with neck pain but still showed up to work. Side business for Papa is becoming real. Feeding India opportunity still alive.',
 'Tired. Stiff. Still moving forward.',
 ARRAY['B.4', 'B.5'],
 ARRAY['Follow up with Feeding India Rohit', 'Carve out fixed hours for Papa automation board']),

('Chetan I will kill you', '2026-03-12',
 'Planned a morning run but woke up with a severe headache. Kotak notice period causing stress — max 1.5 months required by PB. Received Figma design change request from Zomato (Feeding India). Initially worried about being a Figma-heavy PM, but reframed: I am a design-led PM, not data-led — that could be an advantage. Cancelled last ticket at work to focus on Zomato problem statement.',
 'Stressful day navigating notice period constraints and unexpected Figma assignment from Zomato. Ended with positive reframe — design-led PM identity is a strength.',
 'Anxious but reframing positively',
 ARRAY['B.5', 'B.3'],
 ARRAY['Prepare Zomato Figma problem statement', 'Clarify notice period with Kotak HR']),

('Start of a new beginning', '2026-03-09',
 'Morning yoga for recovery. Received PolicyBazaar offer — mailed them and got an instant response. Informed Prerna first, then parents and friends. Prerna ordered pizza to celebrate. Very excited for the time ahead — trips, fitness, AI skills. She was suffering from cramps; pampered her a lot.',
 'Got the PolicyBazaar offer — a milestone day. Celebrated with Prerna who ordered pizza. Feeling hopeful and energised about the next chapter.',
 'Really happy — got the offer!',
 ARRAY['B.5', 'C.2', 'A.1'],
 ARRAY['Wait for offer letter with compensation clarity before resigning', 'Plan 6am gym session tomorrow']),

('Getting back to routine', '2026-03-08',
 'Cousin in Bombay for 4 days — had a lot of fun. Zero money left. Cycle puncture prevented morning cycling. Went to Sanjay Gandhi National Park — managed 45km despite terrible weather. Prerna called many times in 10 minutes because she was worried — that caring means a lot.',
 'Post-family-visit recovery day. 45km cycle despite bad weather and a flat tyre earlier. Prerna''s care during the ride was touching.',
 'Sad but resilient',
 ARRAY['A.1', 'C.2', 'D.1'],
 ARRAY['Fix cycle puncture properly', 'Apologise to Prerna for being rude earlier']),

('My GYM era has started', '2026-02-27',
 'Poker until 4am with Rohan, Shobha, Utkarsh. Woke with migraine next morning. Still went to office. Came home, checked out the gym — purchased membership and paid all dues. Publicly committed to sub-20 min 5K on running club. Prerna posted a great musical video — her skills are improving fast, very proud of her.',
 'Joined gym despite migraine from poker night. Committed publicly to sub-20 5K. Prerna''s musical progress is making Raghav proud.',
 'Energetic, newly committed',
 ARRAY['A.1', 'F.2', 'C.2'],
 ARRAY['Attempt sub-20 min 5K at next race', 'Sleep early for proper recovery']),

('Excited about changing life', '2026-02-26',
 'PolicyBazaar full-time offer is coming — very happy. Went to office without a bath for the first time! Workload relatively less today. Did yoga and meditation in the evening. Applied for iPhone India PM program — very passionate about this role.',
 'Offer news lifting spirits. Low-pressure office day followed by yoga and meditation. Applied for iPhone India PM role.',
 'Happy, forward-moving',
 ARRAY['B.5', 'A.4', 'B.3'],
 ARRAY['Apply for more PM roles at product companies', 'Continue daily yoga and meditation habit']),

('Long cycle ride', '2026-02-19',
 'Woke at 4:30am for Navi Mumbai ride. Reached 90km total — longest ride ever. Palm Beach Road was the highlight — separate cycle lanes, great road. Met a cyclist named Manoj (same name as Papa). Felt very lonely after returning. Visited Kitabkhana (favourite bookstore) in South Bombay. Came back feeling better.',
 'Epic 90km solo cycling ride to Navi Mumbai — a personal record. Post-ride loneliness turned into a meaningful Kitabkhana visit. Self-sufficiency on full display.',
 'Lonely but self-sufficient',
 ARRAY['A.1', 'F.2', 'A.4'],
 ARRAY['Plan next long ride with a friend', 'Visit Kitabkhana more regularly for mental reset']),

('The Ideal day', '2026-02-11',
 'Cycled to Worli Seaface — 50km total. Broke own cycle lock with scissors (lost keys again). 10 min mindfulness at office on arrival. Made a full to-do list. Calm and decisive throughout. Good work session — Sweety called, worked through tasks efficiently.',
 'Perfect balance of fitness, mindfulness, and focused work. 50km cycle followed by a calm, decisive office day with a structured to-do list.',
 'Calm, composed, in flow',
 ARRAY['A.1', 'A.4', 'B.5'],
 ARRAY['Make a spare cycle key', 'Replicate 10-min mindfulness + to-do list routine daily']),

('Crazy morning', '2026-02-05',
 'So excited for cycling that couldn''t sleep. Woke at 4:15am — cycled to Worli, Marine Drive, Gate of India. Completely drained at office. Papa asked for Rs 20,000 — only Rs 25,000 in bank. Left with Rs 4,000 for the month. Had to figure out expenses.',
 'Incredible pre-dawn cycling adventure to Gate of India. Financial stress after sending Rs 20k to Papa left only Rs 4k for the month.',
 'Exhausted but accomplished',
 ARRAY['A.1', 'D.1', 'C.1'],
 ARRAY['Build 2-month expense buffer before Delhi relocation', 'Track monthly cash flow more carefully']),

('Tried to better, loneliness is real', '2026-02-01',
 'Fight with Prerna. Went to Toastmasters debating club via cycle. Prerna texted "what is the topic?" — all anger vanished because she finally appreciated something I do. Ordered her the dress she wanted for a long time. Seeing couples in Mumbai made me miss her deeply. Bombay is the best city but only with the right people.',
 'Post-fight morning redeemed by Prerna''s unexpected appreciation at Toastmasters. Ordered her a surprise dress. Loneliness in Mumbai hits differently when she''s not here.',
 'Fragile but connected',
 ARRAY['C.2', 'A.4', 'C.3'],
 ARRAY['Set up reminders for important dates to avoid repeating fights', 'Plan next visit with Prerna']),

('Worst day in office till date', '2026-02-02',
 'Alarm didn''t ring. Forgot tiffin — need a better system. Data analysis task due EOD from Chetan. Did not speak up with feedback in design meeting — realised being honest is better than being nice. Sweety discussed Daily Save growth — felt I missed a big opportunity by not reporting it.',
 'Chaotic day with missed alarm and forgotten lunch. Key learning: honesty in design reviews beats staying silent. Missed a major growth driver by not reporting Daily Save data.',
 'Pressured, learning from it',
 ARRAY['B.5', 'B.3'],
 ARRAY['Build a reliable morning routine with backup alarm', 'Speak up with honest feedback in next design review']),

('Good day', '2026-02-21',
 'Woke early for run with FRC running club. Rohan and Shobha didn''t wake up — went alone. Led the 7km run. Finished at 6 min/km pace. Short entry but disciplined.',
 'Solo FRC run after teammates bailed. Led the 7km at solid 6 min/km pace. Simple but strong disciplined day.',
 'Strong and leading',
 ARRAY['A.1', 'F.2'],
 ARRAY['Keep showing up to FRC even when others don''t']),

('Valentine with her', '2026-02-14',
 'Did banana ride. Dristi complicated things on Valentine''s Day. Still tried to make it special with Prerna.',
 'Banana ride on Valentine''s Day complicated by Dristi''s involvement. Still focused on making it special with Prerna.',
 'Mixed — complicated',
 ARRAY['C.2'],
 ARRAY['Plan a proper Valentine''s makeup date with Prerna']),

('We had a great day together', '2026-02-15',
 'Did banana ride. Simple, beautiful day together with Prerna.',
 'A simple, joyful day — banana ride with Prerna. No drama, just presence.',
 'Happy, simple joy',
 ARRAY['C.2', 'A.1'],
 ARRAY[]);

-- ── SEED: RESOURCES (from your Notion Resources DB) ───────────

INSERT INTO resources (name, resource_type, topic, area_codes, status, quick_access) VALUES
  ('Reply automation for relationship', 'Resource',  'automation', ARRAY['C.2', 'B.4'], 'Not Started', 'Unpinned'),
  ('How to deploy',                     'Resource',  'automation', ARRAY['B.4'],         'Not Started', 'Unpinned'),
  ('Book: Nudging the unconscious',     'Resource',  'Brain',      ARRAY['A.4'],         'Not Started', 'Unpinned'),
  ('Facts',                             'Resource',  NULL,         ARRAY[],              'Not Started', 'Unpinned'),
  ('New Resource (Example) — Travel',   'Resource',  'Travel',     ARRAY[],              'Archived',    'Pinned'),
  ('New Reference (Example) — Food',    'Reference', 'Food',       ARRAY[],              'Not Started', 'Pinned'),
  ('New Reference (Example) — Fashion', 'Reference', 'Fashion',    ARRAY['A.2'],         'Not Started', 'Pinned'),
  ('New Resource (Example) — Japan',    'Resource',  'Japan',      ARRAY[],              'Not Started', 'Pinned');

-- ── SEED: BUDGET (from your Notion Finance DB) ────────────────

INSERT INTO budget_entries (name, amount, area_code, entry_date, notes) VALUES
  ('Kolkata flights',          -16000, 'C.2', '2026-04-01', 'Flights for Kolkata trip with Prerna'),
  ('Kolkata BNB',              -10000, 'C.2', '2026-04-01', 'Airbnb accommodation in Kolkata'),
  ('Anjanta and Ellora caves',  -6000, 'G.1', '2026-04-01', 'Trip tickets and entry'),
  ('Packers and movers',        -6000, 'E.4', '2026-04-01', 'Delhi relocation logistics'),
  ('Auto (relocation)',         -6000, 'E.4', '2026-04-01', 'Auto transport for relocation'),
  ('Papa CGM',                  -5000, 'C.1', '2026-04-01', 'Continuous glucose monitor for Papa'),
  ('Claude / AI tools',         -2000, 'B.4', '2026-04-01', 'AI tools for VibeCon project'),
  ('Gym membership',            -3500, 'A.1', '2026-02-27', 'Monthly gym membership');

-- ── SEED: INSIGHTS (from journal analysis) ────────────────────

INSERT INTO insights (text, domain, area_code) VALUES
  ('Fitness drops every time there is a social disruption — parents visiting, poker night, friends in town. Your minimum viable training is a 20-min run. Protect that even on disrupted days.', 'A.1 Exercise', 'A.1'),
  ('Career anxiety is rooted in HR timelines, not your actual performance. You cleared 4+ rounds at PolicyBazaar and progressed at Feeding India — trust the process you have already built.', 'B.5 Job', 'B.5'),
  ('You are a design-led PM, not a data-led PM. Figma skills are a competitive advantage, not a gap. The Zomato role leans exactly into your natural edge — reframe it.', 'B.3 Skill Dev', 'B.3'),
  ('Loneliness peaks during solo city exploration, but you convert it into fuel: 90km rides, Kitabkhana visits, Toastmasters. That self-sufficiency is a genuine superpower.', 'C.3 Friends', 'C.3'),
  ('Money stress is recurring — sending Rs 20k to Papa left Rs 4k for the month. Build a 2-month buffer before Delhi relocation. April Kolkata spend alone is Rs 26k.', 'D.1 Budgeting', 'D.1'),
  ('Prerna''s single moment of appreciation ("what is the topic?") erased a whole fight. Build a small ritual to notice and celebrate these moments of genuine connection.', 'C.2 Piri', 'C.2'),
  ('Elite endurance, clear strength gap. The Powai calisthenics class confirmed it — you out-run everyone but fall behind in strength. Add 2 strength sessions per week before Hyrox.', 'F.2 Ironman', 'F.2'),
  ('Not speaking up in design reviews is a pattern you have already diagnosed yourself. Honest specific feedback builds better outcomes and stronger relationships than staying silent.', 'B.5 Job', 'B.5'),
  ('The automation board for Papa''s business is real side income now. Carve out fixed office hours for it rather than working on it opportunistically between other things.', 'B.4 Projects', 'B.4');

-- ── DONE ─────────────────────────────────────────────────────
-- Your Vibe-Mind database is ready.
-- Tables: areas, projects, actions, tasks, journal_entries,
--         resources, captures, insights, budget_entries
-- Seeded: 44 areas, 11 projects, 11 actions, 5 tasks,
--         15 journal entries, 8 resources, 8 budget items, 9 insights
