import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent?key=$apiKey';
  
  final res = await http.post(Uri.parse(url), 
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'model': 'models/gemini-embedding-2',
      'content': {'parts': [{'text': 'What are the grading criteria?'}]}
    })
  );
  
  if (res.statusCode != 200) {
    print('Error: ${res.body}');
    return;
  }
  
  final data = jsonDecode(res.body);
  final embedding = data['embedding']['values'] as List<dynamic>;
  print('Original length: ${embedding.length}');
  
  final truncated = embedding.sublist(0, 768);
  print('Truncated length: ${truncated.length}');
  
  // Now try to query supabase
}
