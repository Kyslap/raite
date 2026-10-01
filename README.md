# Smart Learning Platform Hub (Raite)

Raite is a feature-rich, intelligent learning platform designed for both teachers and students. It features a custom retro-inspired design system and integrates Google's Gemini models for AI tutoring, Retrieval-Augmented Generation (RAG), multimodal OCR study generation, cohort habit intelligence, and GitHub-style learning activity tracking.

---

## 🚀 Features & Architecture

### 1. Authentication & Role Management
- **Overview**: Users can sign up, log in, and log out as either a **Teacher** or a **Student**. 
- **Internal Flow**: 
  - Powered by **Supabase Auth**. User sessions and roles are tracked using a custom `UserModel`.
  - **Instant Demo**: An option on the login screen allows bypassing standard auth to instantly preview the app's UI.
  - **State Management**: `auth_provider.dart` (Riverpod) keeps the global app state in sync with the current user session, cleanly clearing state on logout.

### 2. Teacher Dashboard & Class Management
Teachers have full control over course creation, material distribution, and class monitoring:
- **Class Hub**: Teachers can create classes with unique join codes (or custom codes), manage enrolled student rosters, publish assignments, and broadcast class announcements.
- **Lesson Builder**: Teachers can create structured rich text lessons and syllabus topics.
- **AI Knowledge Base (Dual-Upload Architecture)**: 
  - When a teacher uploads a course PDF, the client extracts raw text in real time.
  - Both the original PDF (for pristine human reading) and clean text (for AI chunking) are stored in Supabase Storage.
  - Teachers can preview and download uploaded materials via secure signed URLs.
- **AI Class Insights**: 
  - Synthesizes real-time analytics by pulling recent student chat logs from `ai_chat_logs`.
  - Uses Gemini to generate markdown reports highlighting common questions, conceptual bottlenecks, and actionable teaching tips.

### 3. Student Dashboard & Class Enrollment
- **Class Code Join**: Students can join classes via 6-character access codes with instant validation and dynamic class switching.
- **Assignments & Announcements**: Students receive class-wide announcements, check upcoming assignment deadlines, and track submission statuses.
- **In-App PDF Viewer**: Securely renders course documents and lecture slides directly within the app alongside the AI Tutor.

### 4. AI Tutor (Lai) & RAG Knowledge Base
Students can learn with **Lai**, a personalized AI tutor grounded directly in the teacher's uploaded course materials:
- **Persistent Chat History**: All conversations with Lai are stored in the `ai_chat_logs` table, allowing students to resume study sessions across devices.
- **RAG Edge Function (`process_document`)**:
  - Automatically splits uploaded documents into clean text chunks without noisy PDF artifacts.
  - Generates 768-dimensional vector embeddings using Google's **Gemini Embedding API** (`gemini-embedding-2` with Matryoshka Representation Learning).
  - Stores vectors in the `document_chunks` table utilizing PostgreSQL `pgvector` HNSW indexing.
- **Vector Search & Source Citations**:
  - Encodes student questions and executes cosine distance search (`<=>`) via the `match_class_documents` RPC function.
  - Injects relevant excerpts along with exact document titles and citations into the prompt.
- **Multimodal & Adaptive Learning**:
  - Supports image and document attachments for homework help.
  - Configurable tone (Academic, Casual, Socratic) and language preferences.
  - Uses `gemini-3.5-flash-lite` for ultra-fast, hallucination-resistant responses.

### 5. Study Decks: Flashcards, Quizzes & Multimodal OCR
An active-recall study suite that transforms static documents into interactive study materials:
- **Multimodal OCR Note Scanner**:
  - Uses Google ML Kit (`google_mlkit_text_recognition`) to extract handwritten or printed text from photos, documents, and textbook pages.
  - Gemini parses the OCR text to automatically generate comprehensive summary notes, flashcard decks, and practice quizzes.
- **Flashcard Deck Mastery**:
  - 3D-flipping cards with 3-tier Leitner-style mastery progression: *Learning*, *Reviewing*, and *Mastered*.
- **Interactive Quiz Runner**:
  - Timed multiple-choice quizzes with randomized questions, instant rationale explanations, and high-score tracking.

### 6. Interactive Daily Goals & Focus Timer
- **Customizable Targets**: Students set daily study targets (e.g. 45 mins) and track progress via an animated retro circular indicator.
- **Dynamic Task Checklist**: Auto-tracks course reading, Lai AI chats, assignment progress, and focused study intervals.
- **Streak Protection**: Maintains daily learning streaks and rewards milestone achievements.
- **Offline & Manual Logging**: Allows students to log offline reading or textbook study time.

### 7. Hive Mind: Cohort Habit Intelligence & Gap Analysis
Bridges the academic achievement gap by analyzing behavioral divergence between performance quartiles:
- **Quartile Differential Tracking**: Compares the top 20% of students against struggling peers across study focus time, quiz mastery, submission timeliness, and AI tutor interaction patterns.
- **AI Pedagogical Synthesis**:
  - Uses Gemini to calculate gap severity (Low, Moderate, Significant, Critical) and generate pedagogical interventions for teachers (e.g., targeted revision topics, low-stakes practice quizzes).
- **Student Peer Nudges**:
  - Displays constructive, non-punitive nudges on the student home screen (e.g., *"Top performers review flashcards within 48h of class"*).

### 8. GitHub-Style Study Activity Heatmap
Encourages daily learning consistency through visual accountability:
- **16-Week Activity Grid**: A 7-row (Monday to Sunday) horizontally scrollable contribution matrix styled with a 5-level retro-green intensity palette (`#EFEBE1`, `#C0DAC6`, `#7FA88B`, `#4F7059`, `#375742`).
- **Unified Activity Accounting**: Automatically records and increments daily points across:
  - Flashcard reviews
  - Quizzes completed
  - Lai AI tutor inquiries
  - Focus timer minutes
  - Assignment submissions
- **Interactive Day Inspector**: Tapping any square opens a detailed bottom sheet displaying the exact breakdown of study activities completed on that date.
- **Omnipresent Placement**: Integrated into the **Home Screen**, **Student Profile**, and **Analytics & Metrics Screen**.

---

## 🎨 Design System (Retro Theme)
- **Architecture**: Enforces a strict **Feature-First Layered Architecture** with Riverpod and GoRouter.
- **Color Palette**:
  - **Primary (Focus)**: Retro Dark Forest Green (`#375742`) with Container (`#4F7059`)
  - **Secondary / Surface**: Retro Warm Gold & Brown (`#685D45` / `#F0E1C2`)
  - **Background**: Warm Cream Canvas (`#FCF9F2`)
- **Typography**: Clean, geometric `Plus Jakarta Sans`.
- **Elevation & Radius**: Soft green-tinted ambient shadows, 8px standard card corners, and 24px pill-shaped buttons.

---

## 🛠️ Tech Stack & Dependencies
- **Framework**: Flutter (Dart 3.x)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter (`go_router`)
- **Backend & Database**: Supabase (PostgreSQL, Supabase Auth, Storage, Edge Functions, `pgvector`)
- **AI / LLM**: Google Gemini API (`gemini-3.5-flash-lite`, `gemini-embedding-2`)
- **Machine Learning / OCR**: Google ML Kit Text Recognition (`google_mlkit_text_recognition`)
- **Document Rendering**: Syncfusion Flutter PDF Viewer (`syncfusion_flutter_pdfviewer`)
- **Code Generation & Models**: Freezed (`freezed`, `json_serializable`)
