# Raite - Smart Learning Platform Hub 🎓🚀

**Raite** is an intelligent, retro-styled learning platform designed to bridge the gap between classroom instruction and independent student mastery. Built with **Flutter**, **Google Gemini**, and **Supabase**, Raite delivers an AI-powered academic ecosystem featuring personalized RAG tutoring (with native **Kapampangan** and **Auto** dialect detection), real multimodal OCR study generation, cohort habit intelligence (Hive Mind), and gamified learning consistency tracking.

---

## 🌟 Key Highlights & Feature Matrix

### 1. 🤖 Lai AI Tutor (RAG & Multilingual Intelligence)
- **Retrieval-Augmented Generation (RAG)**: Grounded in teacher-uploaded syllabus documents, slides, and project templates using vector embeddings (`gemini-embedding-2`).
- **Kapampangan & Auto Dialect Detection**:
  - **Auto Mode**: Automatically detects the student's language, dialect, or multilingual code-switching (English, Tagalog, Taglish, or Kapampangan) and replies naturally in that same tongue.
  - **Kapampangan (Amanung Sisuan)**: Native regional support tailored for Central Luzon / Pampanga learners with culturally authentic phrasing and technical analogies.
- **Pedagogical Tones**: Switch between *Academic*, *Friendly*, *Socratic*, and *Vintage/Strict* teaching personas.
- **Step-by-Step Problem Solving**: Structured breakdown cards for technical topics like Critical Path Method (CPM), Work Breakdown Structures (WBS), and formulas.
- **Smart Fallback Engine**: Fully functional offline fallback with typewriter streaming to ensure zero demo disruptions.

### 2. 📸 Multimodal OCR Note Scanner
- **Real-Device Text Recognition**: Powered by Google ML Kit to scan physical textbooks, whiteboard diagrams, and handwritten notes.
- **Instant Study Artifact Generation**: Transforms captured text into:
  - Concise academic summary notes
  - Interactive 3D flip-card study decks
  - Formative practice quizzes with instant answer feedback and streak credits

### 3. 🧠 Hive Mind: Cohort Habit Intelligence (For Teachers)
- **Pedagogical Telemetry**: Synthesizes real-time chat telemetry, quiz retakes, and study spacing into high-level cohort analyses.
- **Habit Gap Identification**: Contrasts behavioral data between the top quartile and at-risk students (e.g., flashcard review spacing, milestone preparation).
- **Automated Teacher Interventions**: Recommends targeted, high-leverage pedagogical steps (e.g., targeted 15-minute concept breakouts, pre-sprint practice drops).
- **Peer Habit Nudges**: Displays research-backed habit insights to students to inspire sustainable study routines.

### 4. 📈 Gamified Learning Habits & Consistency
- **Unified 4-Day Learning Streak**: Tracked consistently across the Daily Goals Progress Card, Profile, Metrics, and Activity Heatmap.
- **GitHub-Style 16-Week Heatmap**: Visual contribution matrix capturing card reviews, quizzes, tutor inquiries, and timer sessions.
- **Interactive Focus Timer**: Integrated study clock (15m, 25m, 45m Pomodoro intervals) that automatically logs minutes toward daily goals.

### 5. 🧑‍🏫 Teacher Management Suite
- **Class Hub**: Manage enrolled student rosters, view and grade PDF project submissions (Charters, WBS diagrams, Sprint Backlogs).
- **Lesson Publishing**: Create and post structured lesson plans with target objectives, prerequisites, and reference attachments.
- **Insights Tab**: Deep cohort analytics, habit metrics, and student confusion heatmaps.
- **Teacher Profile**: Configure Lai AI teaching styles, alert thresholds, and quick-switch roles.

---

## 📚 Curriculum Focus: Software Project Management (PM-301)

Raite showcases an academic focus on **Software Project Management (PM-301)**:
- **Work Breakdown Structure (WBS)**: 100% rule, deliverable decomposition, work packages.
- **Critical Path Method (CPM)**: Zero-float sequences, early/late start calculations, project duration forecasting.
- **Agile & Scrum**: 2-week timeboxed Sprints, Daily Scrums, Product Owner/Scrum Master roles.
- **Risk Management**: Probability-Impact matrix evaluation and mitigation planning.

---

## 🔑 Demo Access & Rapid Evaluation

For streamlined demo presentations, credentials are automatically populated on both Sign In and Sign Up:

| Role | Name | Email | Password |
| :--- | :--- | :--- | :--- |
| **Student** | Ann Tokin | `tokina@students.nu-clark.edu.ph` | *(pre-filled)* |
| **Teacher** | Mark Lagman | `lagmanm@teachers.nu-clark.edu.ph` | *(pre-filled)* |

---

## 🛠️ Architecture & Tech Stack

```text
lib/
├── core/                  # App-wide shared themes, routing, utilities
│   ├── theme/             # Retro Academic Theme (Plus Jakarta Sans, Forest Green, Cream)
│   ├── routing/           # Declarative GoRouter configuration
│   └── network/           # Dio HTTP client configuration
├── features/              # Feature-First Layered Architecture
│   ├── ai_tutor/          # Lai AI Chat, RAG vector retrieval, dialect modes
│   ├── auth/              # Supabase Auth, prefilled demo credentials
│   ├── class/             # Student Class Hub, syllabus materials, submissions
│   ├── contributions/     # 16-week GitHub-style activity heatmap
│   ├── daily_goals/       # Daily study goals, 4-day streak engine, focus timer
│   ├── hive_mind/         # Cohort habit intelligence & teacher interventions
│   ├── home/              # Student dashboard, quick action grid, study spotlights
│   ├── metrics/           # Academic performance analytics & milestones
│   ├── ocr_scanner/       # Google ML Kit camera/gallery OCR text extraction
│   ├── profile/           # Student/Teacher profiles, role switching, settings
│   ├── study_deck/        # 3D interactive flashcard decks & mastery quizzes
│   └── teacher/           # Teacher dashboard, classes, lesson builder, analytics
└── main.dart              # Entrypoint with Supabase & Riverpod initialization
```

### Technologies Used
- **Frontend**: Flutter (Channel stable, Dart 3)
- **State Management**: Flutter Riverpod
- **Routing**: GoRouter
- **Design System**: Retro Academic Palette (`#375742` Dark Green, `#FCF9F2` Warm Cream, `#685D45` Gold)
- **AI & LLM**: Google Gemini API (`gemini-3.1-flash-lite`, `gemini-embedding-2`)
- **Vision & OCR**: Google ML Kit Text Recognition (`google_mlkit_text_recognition`)
- **Backend & Vector DB**: Supabase (PostgreSQL, `pgvector`, Auth, Storage)
- **Document Viewing**: Syncfusion Flutter PDF Viewer

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.13+ installed
- Dart SDK installed
- Android SDK or iOS toolchain / Chrome for Web

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Kyslap/raite.git
   cd raite
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**:
   Create a `.env` file in the project root:
   ```env
   SUPABASE_URL=https://your-supabase-url.supabase.co
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GEMINI_API_KEY=your_gemini_api_key
   ```

4. **Run the Application**:
   ```bash
   flutter run
   ```
