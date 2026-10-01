# Raite - Smart Learning Platform Hub 🚀

Raite is an intelligent learning platform that empowers both teachers and students. By integrating Google's Gemini models, it offers personalized AI tutoring, multimodal OCR study generation, cohort habit intelligence, and gamified learning tracking.

## 🌟 What it does

### For Teachers
- **Class Hub**: Create classes, manage enrolled student rosters, publish assignments, and broadcast announcements.
- **AI Knowledge Base**: Upload course PDFs. The system extracts raw text and generates vector embeddings for the AI tutor.
- **AI Class Insights & Hive Mind**: Synthesizes real-time analytics from student interactions to highlight conceptual bottlenecks. Compares behavioral patterns between performance quartiles to recommend actionable pedagogical interventions.

### For Students
- **Lai AI Tutor (RAG)**: A personalized AI tutor grounded directly in the teacher's uploaded materials. It features persistent chat history and utilizes vector search for accurate, hallucination-resistant answers with source citations.
- **Multimodal OCR Note Scanner**: Snap a photo of handwritten notes or textbooks. The app uses Google ML Kit and Gemini to automatically generate summary notes, 3D flashcard decks, and practice quizzes.
- **Gamified Learning Tracking**:
  - **Daily Goals & Focus Timer**: Track focused study intervals and maintain learning streaks.
  - **GitHub-Style Study Heatmap**: A 16-week visual contribution matrix that records flashcard reviews, quizzes, Lai AI tutor inquiries, and assignment submissions to encourage daily consistency.

## 🛠️ How we built it

- **Framework**: Flutter
- **Backend & Database**: Supabase (PostgreSQL, Auth, Storage, Edge Functions, `pgvector`)
- **AI / LLM**: Google Gemini API (`gemini-3.5-flash-lite`, `gemini-embedding-2`)
- **Machine Learning**: Google ML Kit Text Recognition
- **Document Rendering**: Syncfusion Flutter PDF Viewer
