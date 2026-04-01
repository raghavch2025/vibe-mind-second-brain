-- Create Areas Table
CREATE TABLE areas (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_code VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Projects Table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    area_id INT REFERENCES areas(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Actions Table
CREATE TABLE actions (
    id SERIAL PRIMARY KEY,
    project_id INT REFERENCES projects(id),
    description TEXT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Tasks Table
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    action_id INT REFERENCES actions(id),
    title VARCHAR(100) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Journal Entries Table
CREATE TABLE journal_entries (
    id SERIAL PRIMARY KEY,
    area_id INT REFERENCES areas(id),
    entry DATE NOT NULL,
    content TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Resources Table
CREATE TABLE resources (
    id SERIAL PRIMARY KEY,
    area_id INT REFERENCES areas(id),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Captures Table
CREATE TABLE captures (
    id SERIAL PRIMARY KEY,
    area_id INT REFERENCES areas(id),
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Insights Table
CREATE TABLE insights (
    id SERIAL PRIMARY KEY,
    area_id INT REFERENCES areas(id),
    insight TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Budget Entries Table
CREATE TABLE budget_entries (
    id SERIAL PRIMARY KEY,
    area_id INT REFERENCES areas(id),
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Indexes
CREATE INDEX idx_area_name ON areas (name);
CREATE INDEX idx_project_area ON projects (area_id);
CREATE INDEX idx_action_project ON actions (project_id);
CREATE INDEX idx_task_action ON tasks (action_id);
CREATE INDEX idx_journal_entry_area ON journal_entries (area_id);
CREATE INDEX idx_resource_area ON resources (area_id);
CREATE INDEX idx_capture_area ON captures (area_id);
CREATE INDEX idx_insight_area ON insights (area_id);
CREATE INDEX idx_budget_entry_area ON budget_entries (area_id);

-- Enable Row-Level Security
ALTER TABLE areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE captures ENABLE ROW LEVEL SECURITY;
ALTER TABLE insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_entries ENABLE ROW LEVEL SECURITY;

-- Add Policies for Row-Level Security
-- Example policy - adjust as necessary based on your strategy
CREATE POLICY select_areas ON areas FOR SELECT USING (true); -- Allow all to select
-- Add additional policies as needed for other tables...

-- Seed Data for Areas A-J
INSERT INTO areas (name, parent_code) VALUES
('Area A', NULL),
('Area B', NULL),
('Area C', NULL),
('Area D', NULL),
('Area E', NULL),
('Area F', NULL),
('Area G', NULL),
('Area H', NULL),
('Area I', NULL),
('Area J', NULL);