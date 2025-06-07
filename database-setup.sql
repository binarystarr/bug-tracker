-- Create the bugs table in Supabase
CREATE TABLE bugs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  assigned_to VARCHAR(255),
  reporter VARCHAR(255)
);

-- Create an index on status for faster filtering
CREATE INDEX idx_bugs_status ON bugs(status);

-- Create an index on priority for faster filtering  
CREATE INDEX idx_bugs_priority ON bugs(priority);

-- Create an index on created_at for faster ordering
CREATE INDEX idx_bugs_created_at ON bugs(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE bugs ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows all operations for now (you can make this more restrictive)
CREATE POLICY "Allow all operations on bugs" ON bugs
FOR ALL USING (true);

-- Function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_bugs_updated_at 
    BEFORE UPDATE ON bugs 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column(); 