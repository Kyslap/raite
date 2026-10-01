# Smart Learning Platform Hub (Raite)

Raite is a feature-rich, intelligent learning platform designed for both teachers and students. It features a custom retro-inspired design system and integrates Google's Gemini models for AI tutoring and Retrieval-Augmented Generation (RAG).

## 🚀 Features & Internal Architecture

### 1. Authentication & Role Management
- **Overview**: Users can sign up and log in as either a **Teacher** or a **Student**. 
- **Internal Flow**: 
  - Powered by **Supabase Auth**. User sessions and roles are tracked using a custom `UserModel`.
  - **Instant Demo**: An option on the login screen allows bypassing standard auth to instantly view the app's UI (Note: API functions that require Row Level Security will not work in demo mode).
  - **State Management**: `auth_provider.dart` (Riverpod) keeps the global app state in sync with the current user session.

### 2. Teacher Dashboard
Teachers have full control over course creation and content management.
- **Class Creation**: Teachers can create new classes (e.g., "Intro to Astrophysics"), which generate unique join codes (or accept custom codes). Stored in the `classes` Supabase table.
- **Lesson Builder**: Teachers can create rich text lessons. Stored in the `lessons` table.
- **AI Knowledge Base (Uploads)**: 
  - Teachers can upload `.pdf` or `.txt` materials directly to the app. 
  - The client (Flutter) extracts the raw text from the documents (using `syncfusion_flutter_pdf`) and inserts the text into the `class_documents` table in Supabase.

### 3. Student Dashboard
- **Class Enrollment**: Students can use a Class Join Code to enroll in a class, giving them access to its lessons and knowledge base.
- **Lesson Viewer**: Students can browse and read lessons published by their teachers.

### 4. AI Tutor (Nova) & RAG Knowledge Base
The most advanced feature of the platform. Students can chat with "Nova", an AI tutor that knows exactly what the teacher uploaded.
- **Edge Function (Backend Processing)**: 
  - When a teacher uploads a document, a Supabase Edge Function (`process_document` written in TypeScript) is automatically triggered.
  - It splits the massive text document into smaller "chunks".
  - It calls the **Gemini Embedding API** (`gemini-embedding-2` with Matryoshka Representation Learning set to 768 dimensions) to turn each text chunk into a dense vector array.
  - The vectors are saved to the `document_chunks` table, which uses Postgres `pgvector` indexing.
- **Vector Search (Frontend Retrieval)**:
  - When a student asks a question on the AI Tutor screen, the Flutter app intercepts the prompt before sending it to the chat model.
  - It calls the Gemini API to embed the student's question into a 768-dimensional vector.
  - It triggers a Postgres RPC function (`match_class_documents`) in Supabase. This function calculates the **cosine distance** (`<=>`) between the student's question vector and all the vectors in the database, fetching the top 3 most relevant paragraphs.
- **Context Injection (Generation)**:
  - The highly relevant text chunks are seamlessly injected into Nova's system instructions.
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
