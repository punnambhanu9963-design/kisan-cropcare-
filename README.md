# 🌾 KISAN CROPCARE AI — Mobile-First Agricultural Companion

> **A production-ready, mobile-first AI agricultural assistant built with React / Next.js, TypeScript, Supabase, and Vanilla CSS.**  
> Paradigm: **SEES → LISTENS → GUIDES → DIAGNOSES → RECOMMENDS → REMEMBERS → FOLLOWS UP**

---

## 🌟 Core Features

### 1. 📷 Signature Feature: Live Crop Scan (`/scan/live`)
- **Real-Time Camera AI Guidance**: Analyzes camera video feed at 60fps in `<canvas>`.
- **Intelligent Heuristic Alerts**:
  - *"Move 10 cm closer to the leaf"* (foliage coverage check)
  - *"Hold still, camera is moving"* (Laplacian variance motion blur check)
  - *"Too dark, turn on flashlight"* (weighted luminance check)
  - *"Harsh glare, shade the leaf slightly"*
  - *"Show underside of the leaf / tilt camera"*
- **Voice Guidance**: Speaks guidance instructions in the farmer's selected native language so they don't have to read while holding the phone.
- **Multi-Frame Sampling & Auto-Diagnosis**: Automatically locks focus and initiates clinical diagnosis when 3 consecutive high-quality frames are captured.
- **Camera Controls**: Front/back switch, torch/flashlight toggle, and desktop simulation mode.

### 2. 🍅 Tomato Leaf Test Demo Flow (`/diagnose/diag-tomato-demo-01`)
- Built-in one-tap demo for **Tomato Early Blight (*Alternaria solani*)** / Septoria Leaf Spot.
- Realistic procedural leaf canvas with concentric target-board dark spots and chlorotic yellow halos.
- Provides confidence score (94.4%), severity level, differential diagnoses, organic bio-control solutions (Trichoderma viride, Neem extract), verified IPM chemical controls (Mancozeb 75% WP, Copper Oxychloride) with safety precautions, and follow-up timeline.

### 3. 🌐 Multilingual & Voice System (12 Indian Languages)
- **12 Supported Languages**:
  1. English (`en-IN`)
  2. Telugu / తెలుగు (`te-IN`)
  3. Hindi / हिन्दी (`hi-IN`)
  4. Tamil / தமிழ் (`ta-IN`)
  5. Kannada / ಕನ್ನಡ (`kn-IN`)
  6. Malayalam / മലയാളം (`ml-IN`)
  7. Marathi / मराठी (`mr-IN`)
  8. Bengali / বাংলা (`bn-IN`)
  9. Gujarati / ગુજરાતી (`gu-IN`)
  10. Punjabi / ਪੰਜਾਬੀ (`pa-IN`)
  11. Odia / ଓଡ଼ିଆ (`or-IN`)
  12. Urdu / اردو (`ur-IN`)
- **Speech-to-Text (STT)**: Web Speech API microphone input in any selected language.
- **Text-to-Speech (TTS)**: Built-in voice player reading aloud diagnosis findings and chat advice.

### 4. 🤖 Friendly AI Companion: "Kisan Mitra" (`/assistant`)
- Respectful, humble agricultural assistant addressing farmers respectfully (*"Namaste Kisan Bhai / Raithanna"*).
- Aware of user's registered crop context (variety, sowing date, soil type, irrigation method).
- Powered by Google Gemini API with fallback agronomy rule engine.

### 5. 🚜 My Crops & Field Management (`/crops`)
- Register plots with: Crop type, variety, field name, acreage, sowing date, soil classification (Red Sandy, Black Cotton, Alluvial, Clay Loam), irrigation (Drip, Sprinkler, Furrow, Rainfed), GPS/district, and observations.
- Health status badges and direct links to scan specific crops.

### 6. ⏰ Smart Reminders & Follow-Up Tracker (`/reminders`)
- Filter by: **Today**, **Upcoming**, **Overdue**, **Completed**.
- Priority levels: Low, Medium, High, Urgent.
- Actions: Mark Complete, Snooze (1 day, 3 days), Delete.
- One-tap "Add Reminder" directly from diagnosis follow-up checklists.

### 7. 🛟 Help Desk & Feedback (`/help`)
- Ticket submission for Krishi Vigyan Kendra (KVK) agronomists.
- National Kisan Call Center helpline directory: **1800-180-1551** (Toll-free, 22 languages).
- Scan feedback (Helpful 👍 / Not Helpful 👎).

---

## 🗄️ Supabase Backend & Database Setup

The application features **Dual-Mode Architecture**:
- Works out-of-the-box locally with reactive IndexedDB / LocalStorage.
- Instantly connects to Supabase when environment variables are set.

### 1. Database Schema
Execute [`supabase/schema.sql`](supabase/schema.sql) in your Supabase SQL Editor. It creates:
- `profiles`
- `crops`
- `scans`
- `diagnoses`
- `live_sessions` & `live_messages`
- `reminders`
- `notifications`
- `conversations` & `messages`
- `help_requests`
- `feedback`
- Complete **Row Level Security (RLS)** policies and performance indexes.

### 2. Storage Buckets
Execute [`supabase/storage.sql`](supabase/storage.sql) in Supabase SQL Editor:
- `crop-scans`
- `chat-audio`
- `help-attachments`

### 3. Environment Variables
Copy `.env.example` to `.env.local`:
```bash
cp .env.example .env.local
```
Fill in:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...
GEMINI_API_KEY=your_gemini_api_key
```

---

## 🚀 Running Locally

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```
Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 📱 Mobile & PWA Optimization
- Configured with `manifest.json` and offline service worker `sw.js`.
- Mobile safe-area insets (`env(safe-area-inset-bottom)`).
- Low-bandwidth client-side canvas image downscaling to max 1280px (<400KB payload) for 2G/3G rural networks.
- High-contrast sunlight readability mode.
