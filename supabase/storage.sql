-- ==============================================================================
-- KISAN CROPCARE AI — SUPABASE STORAGE BUCKET CONFIGURATION
-- ==============================================================================

-- 1. Create Storage Buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES 
    ('crop-scans', 'crop-scans', true),
    ('chat-audio', 'chat-audio', true),
    ('help-attachments', 'help-attachments', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Storage Policies
CREATE POLICY "Public Read Access for Crop Scans"
ON storage.objects FOR SELECT
USING (bucket_id = 'crop-scans');

CREATE POLICY "Authenticated Users can Upload Crop Scans"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'crop-scans' AND auth.role() = 'authenticated');

CREATE POLICY "Users can Delete their Own Crop Scans"
ON storage.objects FOR DELETE
USING (bucket_id = 'crop-scans' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Chat Audio Policies
CREATE POLICY "Public Read Access for Chat Audio"
ON storage.objects FOR SELECT
USING (bucket_id = 'chat-audio');

CREATE POLICY "Authenticated Users can Upload Chat Audio"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'chat-audio' AND auth.role() = 'authenticated');

-- Help Attachments Policies
CREATE POLICY "Authenticated Users can Upload Help Attachments"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'help-attachments' AND auth.role() = 'authenticated');
