-- ==============================================================================
-- KISAN CROPCARE AI — SUPABASE POSTGRESQL SCHEMA WITH ROW LEVEL SECURITY (RLS)
-- Production schema for crops, scans, diagnoses, live guidance, reminders, chat & feedback
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    phone_number TEXT,
    preferred_language TEXT DEFAULT 'en', -- en, te, hi, ta, kn, ml, mr, bn, gu, pa, or, ur
    state TEXT,
    district TEXT,
    village TEXT,
    farm_size_acres NUMERIC(6, 2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CROPS TABLE
CREATE TABLE IF NOT EXISTS public.crops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    crop_name TEXT NOT NULL,          -- e.g. "Tomato", "Cotton", "Paddy", "Chilli"
    variety TEXT,                     -- e.g. "Arka Rakshak", "Sona Masoori"
    field_name TEXT NOT NULL,         -- e.g. "North Plot 2", "River Bank Field"
    acreage NUMERIC(5, 2),            -- e.g. 2.5 acres
    planting_date DATE,
    soil_type TEXT,                   -- Red Sandy, Black Cotton, Alluvial, Clay Loam
    irrigation_type TEXT,             -- Drip, Sprinkler, Furrow, Rainfed
    location_district TEXT,
    latitude NUMERIC(9, 6),
    longitude NUMERIC(9, 6),
    health_status TEXT DEFAULT 'Healthy', -- Healthy, Needs Attention, Critical
    notes TEXT,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. SCANS TABLE
CREATE TABLE IF NOT EXISTS public.scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES public.crops(id) ON DELETE SET NULL,
    image_url TEXT NOT NULL,
    capture_mode TEXT DEFAULT 'standard', -- 'standard' | 'live'
    quality_metrics JSONB DEFAULT '{}'::jsonb, -- { brightness: 120, blurScore: 88, framingScore: 92 }
    device_info JSONB DEFAULT '{}'::jsonb,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. DIAGNOSES TABLE
CREATE TABLE IF NOT EXISTS public.diagnoses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scan_id UUID REFERENCES public.scans(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES public.crops(id) ON DELETE SET NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    crop_name TEXT NOT NULL,
    plant_part TEXT NOT NULL,            -- "Leaf", "Stem", "Fruit", "Root", "Whole Plant"
    possible_problem TEXT NOT NULL,      -- e.g. "Tomato Early Blight (Alternaria solani)"
    confidence NUMERIC(5, 2) NOT NULL,   -- e.g. 94.5
    severity TEXT NOT NULL,              -- "Mild" | "Moderate" | "Severe" | "Critical"
    symptoms JSONB NOT NULL DEFAULT '[]'::jsonb,
    causes JSONB NOT NULL DEFAULT '[]'::jsonb,
    alternative_possibilities JSONB NOT NULL DEFAULT '[]'::jsonb,
    required_additional_view TEXT,       -- Guidance if certainty was low
    safe_actions JSONB NOT NULL DEFAULT '{"organic": [], "chemical": [], "precautions": []}'::jsonb,
    prevention JSONB NOT NULL DEFAULT '[]'::jsonb,
    follow_up JSONB NOT NULL DEFAULT '{"timeline": "4 days", "checklist": []}'::jsonb,
    raw_ai_response JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. LIVE SESSIONS TABLE (Signature Feature: Live Crop Scan)
CREATE TABLE IF NOT EXISTS public.live_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES public.crops(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'active',        -- 'active' | 'completed' | 'abandoned'
    total_frames_analyzed INT DEFAULT 0,
    guidance_summary TEXT,
    final_diagnosis_id UUID REFERENCES public.diagnoses(id) ON DELETE SET NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE
);

-- 6. LIVE SESSION MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.live_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES public.live_sessions(id) ON DELETE CASCADE,
    guidance_type TEXT NOT NULL,         -- 'distance', 'lighting', 'angle', 'motion', 'feature_found'
    message_text TEXT NOT NULL,
    audio_spoken BOOLEAN DEFAULT TRUE,
    frame_metrics JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. REMINDERS TABLE
CREATE TABLE IF NOT EXISTS public.reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES public.crops(id) ON DELETE SET NULL,
    diagnosis_id UUID REFERENCES public.diagnoses(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT DEFAULT 'Treatment',   -- 'Treatment', 'Inspection', 'Fertilizer', 'Watering', 'Harvest'
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    recurrence TEXT DEFAULT 'none',      -- 'none' | 'daily' | 'weekly' | 'biweekly' | 'monthly'
    priority TEXT DEFAULT 'Medium',      -- 'Low' | 'Medium' | 'High' | 'Urgent'
    status TEXT DEFAULT 'upcoming',      -- 'today' | 'upcoming' | 'completed' | 'overdue'
    notification_channels JSONB DEFAULT '["in_app"]'::jsonb,
    snoozed_until TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT DEFAULT 'reminder',        -- 'reminder', 'scan_update', 'weather_alert', 'system'
    is_read BOOLEAN DEFAULT FALSE,
    action_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. CONVERSATIONS & MESSAGES (Kisan Mitra Companion)
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES public.crops(id) ON DELETE SET NULL,
    title TEXT DEFAULT 'Crop Care Chat',
    language TEXT DEFAULT 'en',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    role TEXT NOT NULL,                  -- 'user' | 'assistant' | 'system'
    content TEXT NOT NULL,
    audio_url TEXT,
    context_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. HELP DESK REQUESTS TABLE
CREATE TABLE IF NOT EXISTS public.help_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    category TEXT NOT NULL,              -- 'Agronomy Expert Consult', 'Pest Outbreak', 'App Technical Issue'
    subject TEXT NOT NULL,
    description TEXT NOT NULL,
    priority TEXT DEFAULT 'Medium',
    status TEXT DEFAULT 'Open',          -- 'Open', 'In Review', 'Resolved'
    contact_phone TEXT,
    attachments JSONB DEFAULT '[]'::jsonb,
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. FEEDBACK TABLE
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    scan_id UUID REFERENCES public.scans(id) ON DELETE SET NULL,
    rating TEXT NOT NULL,                -- 'helpful' | 'not_helpful'
    comments TEXT,
    actual_disease_found TEXT,           -- farmer corrected diagnosis if known
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- INDEXES FOR HIGH-PERFORMANCE QUERIES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_crops_user_id ON public.crops(user_id);
CREATE INDEX IF NOT EXISTS idx_scans_user_id ON public.scans(user_id);
CREATE INDEX IF NOT EXISTS idx_scans_crop_id ON public.scans(crop_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_scan_id ON public.diagnoses(scan_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_user_id ON public.diagnoses(user_id);
CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON public.reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_reminders_due_date ON public.reminders(due_date);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diagnoses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.help_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- Profiles Policy
CREATE POLICY "Users can manage their own profile"
    ON public.profiles FOR ALL
    USING (auth.uid() = id);

-- Crops Policy
CREATE POLICY "Users can manage their own crops"
    ON public.crops FOR ALL
    USING (auth.uid() = user_id);

-- Scans Policy
CREATE POLICY "Users can manage their own scans"
    ON public.scans FOR ALL
    USING (auth.uid() = user_id);

-- Diagnoses Policy
CREATE POLICY "Users can view their own diagnoses"
    ON public.diagnoses FOR ALL
    USING (auth.uid() = user_id);

-- Live Sessions Policy
CREATE POLICY "Users can manage their own live sessions"
    ON public.live_sessions FOR ALL
    USING (auth.uid() = user_id);

-- Reminders Policy
CREATE POLICY "Users can manage their own reminders"
    ON public.reminders FOR ALL
    USING (auth.uid() = user_id);

-- Notifications Policy
CREATE POLICY "Users can manage their own notifications"
    ON public.notifications FOR ALL
    USING (auth.uid() = user_id);

-- Conversations & Messages Policy
CREATE POLICY "Users can manage their own conversations"
    ON public.conversations FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their conversation messages"
    ON public.messages FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.conversations c 
            WHERE c.id = messages.conversation_id AND c.user_id = auth.uid()
        )
    );

-- Help Requests Policy
CREATE POLICY "Users can manage their help requests"
    ON public.help_requests FOR ALL
    USING (auth.uid() = user_id);

-- Feedback Policy
CREATE POLICY "Users can manage their feedback"
    ON public.feedback FOR ALL
    USING (auth.uid() = user_id);
