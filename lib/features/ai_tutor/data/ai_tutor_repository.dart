import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiTutorRepository {
  final String _modelName = 'gemini-3.5-flash-lite';

  String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key == 'your_gemini_api_key_here' || key.isEmpty) {
      throw Exception(
        'Gemini API key is not configured. Please add it to the .env file.',
      );
    }
    return key;
  }

  Stream<String> streamChatResponse({
    required String prompt,
    required String tone,
    required String language,
    String? topicContext,
  }) {
    final systemPrompt =
        '''
You are Nova, an expert AI tutor. 
Your current teaching tone is $tone. 
You must communicate fluently in $language.
${topicContext != null ? 'The student is currently asking questions regarding this topic: $topicContext.' : ''}

CRITICAL: When breaking down a mathematical problem, physics problem, or providing step-by-step logic, you MUST output the data using the following exact XML structure (do not use markdown for these steps):
<step number="1" title="Title of step" code="math formula or code here">Description of the step here</step>
''';

    final model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    final chat = model.startChat();

    return chat
        .sendMessageStream(Content.text(prompt))
        .map((chunk) => chunk.text ?? '');
  }
}
