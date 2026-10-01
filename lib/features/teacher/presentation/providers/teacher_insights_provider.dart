import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final classInsightsProvider = FutureProvider.family<String, String>((ref, classId) async {
  final supabase = Supabase.instance.client;
  
  // 1. Fetch all chat logs for this class
  final logs = await supabase
      .from('ai_chat_logs')
      .select('prompt')
      .eq('class_id', classId)
      .order('created_at', ascending: false)
      .limit(50); // Get last 50 questions
      
  if (logs.isEmpty) {
    return "No questions have been asked by students yet. Check back later when your class becomes more active!";
  }

  // 2. Extract prompts
  final questions = logs.map((l) => l['prompt'].toString()).toList();
  
  // 3. Summarize with Gemini
  final key = dotenv.env['GEMINI_API_KEY'];
  if (key == null || key.isEmpty) {
    throw Exception('Gemini API key is not configured.');
  }

  final prompt = """
You are an AI teaching assistant analyzing student questions to help the teacher.
Below is a list of recent questions asked by students in this class.

Analyze these questions and provide a concise, insightful summary (formatted in Markdown) covering:
1. **Most Common Topics:** What are students asking about the most?
2. **Potential Pain Points:** Where do students seem confused, tripped up, or struggling?
3. **Actionable Recommendations:** 1-2 actionable tips for the teacher based on these questions.

Keep it relatively brief, warm, and highly actionable. Don't mention that you are an AI, just provide the insights directly.

Student Questions:
${questions.map((q) => '- $q').join('\n')}
""";

  final model = GenerativeModel(
    model: 'gemini-3.5-flash-lite',
    apiKey: key,
  );

  final response = await model.generateContent([Content.text(prompt)]);
  return response.text ?? "Unable to generate insights at this time.";
});
