-- LearningSteps API Database Setup
-- This file is run by the Postgres container on first initialization.

CREATE TABLE IF NOT EXISTS entries (
    id VARCHAR PRIMARY KEY,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_entries_created_at ON entries(created_at);
CREATE INDEX IF NOT EXISTS idx_entries_data_gin ON entries USING GIN (data);

-- Optional test data
-- INSERT INTO entries (id, data, created_at, updated_at)
-- VALUES ('test-123', '{"work": "SQL", "struggle": "JSONB", "intention": "Practice"}', NOW(), NOW());
