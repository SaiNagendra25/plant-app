-- Create the plants table
CREATE TABLE plants (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  species TEXT,
  watering_frequency_days INT,
  last_watered_at TIMESTAMPTZ,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE plants ENABLE ROW LEVEL SECURITY;

-- Create policy for users to view their own plants
CREATE POLICY "Users can view their own plants"
ON plants FOR SELECT
USING (auth.uid() = user_id);

-- Create policy for users to insert their own plants
CREATE POLICY "Users can insert their own plants"
ON plants FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own plants
CREATE POLICY "Users can update their own plants"
ON plants FOR UPDATE
USING (auth.uid() = user_id);

-- Create policy for users to delete their own plants
CREATE POLICY "Users can delete their own plants"
ON plants FOR DELETE
USING (auth.uid() = user_id);

-- Create a public bucket for plant images
INSERT INTO storage.buckets (id, name, public)
VALUES ('plant_images', 'plant_images', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Create policy for users to view images in the public bucket
CREATE POLICY "Public can view plant images"
ON storage.objects FOR SELECT
USING (bucket_id = 'plant_images');

-- Create policy for authenticated users to upload images
CREATE POLICY "Authenticated users can upload plant images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'plant_images');
