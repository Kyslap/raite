# Smart Learning Platform Hub (Raite)

Raite is a feature-rich, intelligent learning platform designed for both teachers and students. It features a custom retro-inspired design system and integrates Google's Gemini models for AI tutoring and Retrieval-Augmented Generation (RAG).

## 🚀 Features & Internal Architecture

### 1. Authentication & Role Management
- **Overview**: Users can sign up, log in, and log out as either a **Teacher** or a **Student**. 
- **Internal Flow**: 
  - Powered by **Supabase Auth**. User sessions and roles are tracked using a custom `UserModel`.
  - **Instant Demo**: An option on the login screen allows bypassing standard auth to instantly view the app's UI (Note: API functions that require Row Level Security will not work in demo mode).
  - **State Management**: `auth_provider.dart` (Riverpod) keeps the global app state in sync with the current user session. Auth state changes are handled gracefully (e.g., logging out safely drops session data).

### 2. Teacher Dashboard
Teachers have full control over course creation and content management.
- **Class Creation**: Teachers can create new classes (e.g., "Intro to Astrophysics"), which generate unique join codes (or accept custom codes). Stored in the `classes` Supabase table.
- **Lesson Builder**: Teachers can create rich text lessons. Stored in the `lessons` table.
- **AI Knowledge Base (Uploads)**: 
  - Uses a **dual-upload architecture**. When a teacher uploads a `.pdf`, the client extracts the raw text. 
  - Both the original pristine `.pdf` (for human viewing) and the extracted `.txt` (for AI parsing) are uploaded to Supabase Storage.
  - Teachers have a dedicated section in their dashboard to view and download all their uploaded materials securely via Signed URLs.
- **AI Class Insights**: 
  - A dynamic dashboard widget that synthesizes real-time analytics for the teacher. 
  - It pulls recent student chat logs from the `ai_chat_logs` table and uses Gemini to generate a warm, markdown-formatted report outlining common student questions, potential pain points, and actionable teaching tips.

### 3. Student Dashboard
- **Class Enrollment**: Students can use a Class Join Code to enroll in a class, giving them access to its lessons and knowledge base.
- **Lesson Viewer**: Students can browse and read lessons published by their teachers.
- **Material Viewing**: Students can securely view the original, formatted PDF documents uploaded by the teacher right from the AI Tutor interface.

### 4. AI Tutor (Nova) & RAG Knowledge Base
The most advanced feature of the platform. Students can chat with "Nova", an AI tutor that knows exactly what the teacher uploaded.
- **Persistent Chat History**: All conversations with Nova are securely saved to the `ai_chat_logs` table (including the user's prompt and AI's response), allowing students to pick up their study sessions right where they left off.
- **Edge Function (Backend Processing)**: 
  - When a teacher uploads a document, a Supabase Edge Function (`process_document`) is triggered.
  - It fetches the text from the `raw_text_url` if available (falling back to `file_url`) to cleanly split the text into chunks without messy PDF metadata.
  - It calls the **Gemini Embedding API** (`gemini-embedding-2` with Matryoshka Representation Learning set to 768 dimensions) to turn each text chunk into a dense vector array.
  - The vectors are saved to the `document_chunks` table, which uses Postgres `pgvector` indexing.
- **Vector Search (Frontend Retrieval)**:
  - When a student asks a question, the Flutter app calls the Gemini API to embed the student's question into a 768-dimensional vector.
  - It triggers a Postgres RPC function (`match_class_documents`) to calculate the **cosine distance** (`<=>`) between the question and the database vectors.
  - Crucially, it retrieves the original `document_title` and `document_id` for every matched chunk to act as a **Source Citation**.
- **Context Injection (Generation)**:
  - The relevant text chunks and their explicit file names are seamlessly injected into Nova's system instructions.
  - This allows the AI to accurately identify which document it is summarizing, avoiding "outlier" hallucinations.
  - The final prompt is sent to `gemini-3.5-flash-lite`, which responds to the student accurately using *only* the teacher's materials.

### 5. Design System (Retro Theme)
- **Architecture**: A "Feature-First Layered Architecture" enforced via Riverpod and GoRouter.
- **Aesthetics**: Custom-built Retro Theme (`AppTheme`). Uses deep retro greens (`#375742`), soft cream backgrounds (`#FCF9F2`), and retro gold accents, styled with `Plus Jakarta Sans` typography. 

## 🛠️ Tech Stack
- **Framework**: Flutter (Dart)
- **Backend & Database**: Supabase (PostgreSQL, Edge Functions, pgvector)
- **AI/LLM**: Google Gemini (`gemini-3.5-flash-lite` for chat, `gemini-embedding-2` for RAG)
- **State Management**: Riverpod
- **Routing**: GoRouter
