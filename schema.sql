-- Enable pgcrypto extension to use gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users Table: Stores user information
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    username VARCHAR(50) UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Goals Table: Stores the high-level, long-term goals
CREATE TABLE goals (
    goal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    goal_type VARCHAR(50) NOT NULL, -- 'TARGET_VALUE', 'HABIT_FORMATION', 'HABIT_QUITTING'
    target_value NUMERIC,
    target_unit VARCHAR(50),
    target_date DATE,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'archived'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habits Table: The specific, repeatable actions linked to a goal
CREATE TABLE habits (
    habit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID REFERENCES goals(goal_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    frequency_type VARCHAR(50), -- 'daily', 'weekly'
    frequency_value INT,
    is_bad_habit BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Progress Log Table: Records every single action a user takes
CREATE TABLE progress_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID REFERENCES habits(habit_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    value_achieved NUMERIC DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);