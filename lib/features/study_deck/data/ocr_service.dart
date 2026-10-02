import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../domain/study_models.dart';

class OcrService {
  static const List<String> _geminiModels = [
    'gemini-3.1-flash-lite',
    'gemini-2.5-flash-lite',
    'gemini-3.8-flash',
    'gemini-flash-latest',
  ];

  Future<OcrScanResult> scanAndGenerateStudyMaterial(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final ext = fileName.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(ext);
    final isPdf = ext == 'pdf';
    final isText = ['txt', 'md', 'csv'].contains(ext);

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final hasValidKey = apiKey != null &&
        apiKey != 'your_gemini_api_key_here' &&
        apiKey.trim().isNotEmpty;

    if (!hasValidKey) {
      throw Exception(
        'Gemini API key is missing or invalid in .env file. Please provide a valid GEMINI_API_KEY.',
      );
    }

    String? extractedPdfOrText;
    List<int>? rawBytes;
    String? mimeType;

    if (isImage) {
      rawBytes = await file.readAsBytes();
      mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';
    } else if (isPdf) {
      final bytes = await file.readAsBytes();
      try {
        final document = PdfDocument(inputBytes: bytes);
        final text = PdfTextExtractor(document).extractText();
        document.dispose();
        if (text.trim().isNotEmpty) {
          extractedPdfOrText = text;
        }
      } catch (e) {
        debugPrint('PdfTextExtractor notice: $e');
      }

      // If no text was extracted from PDF, treat it as a scanned document
      if (extractedPdfOrText == null || extractedPdfOrText.trim().isEmpty) {
        rawBytes = bytes;
        mimeType = 'application/pdf';
      }
    } else if (isText) {
      extractedPdfOrText = await file.readAsString();
    } else {
      rawBytes = await file.readAsBytes();
      mimeType = 'application/octet-stream';
    }

    // Call Gemini with prioritized model fallback
    String lastError = '';
    for (final modelName in _geminiModels) {
      try {
        final result = await _callGeminiOcr(
          apiKey: apiKey,
          modelName: modelName,
          fileName: fileName,
          filePath: file.path,
          extractedTextContent: extractedPdfOrText,
          rawBytes: rawBytes,
          mimeType: mimeType,
        );

        if (result != null) {
          return result;
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('Gemini model $modelName failed: $e, trying next model...');
      }
    }

    // If text was extracted from PDF/text document, construct real study material from it
    if (extractedPdfOrText != null && extractedPdfOrText.trim().isNotEmpty) {
      return _buildResultFromExtractedText(
        text: extractedPdfOrText,
        fileName: fileName,
        filePath: file.path,
      );
    }

    throw Exception(
      'AI OCR Vision scan failed across all available models: $lastError. Please verify your connection or document format.',
    );
  }

  Future<OcrScanResult?> _callGeminiOcr({
    required String apiKey,
    required String modelName,
    required String fileName,
    required String filePath,
    String? extractedTextContent,
    List<int>? rawBytes,
    String? mimeType,
  }) async {
    const prompt = '''
You are an expert AI OCR and academic tutor.
Analyze the provided document/image thoroughly.
1. Transcribe ALL verbatim text, headings, formulas, definitions, and concepts shown.
2. Provide a 2-3 sentence executive summary explaining what this material teaches.
3. Extract 4-6 high-yield Flashcards (Front: Concept/Question, Back: Concise clear definition or formula, Topic).
4. Generate a 3-4 question Multiple Choice Quiz testing understanding of this material (Question, 4 Options, correctIndex 0-3, and Explanation).

Return pure JSON with this exact structure:
{
  "transcription": "Full verbatim text extracted from the document...",
  "summary": "Concise overview of the material...",
  "keyConcepts": ["Concept 1", "Concept 2", "Concept 3"],
  "flashcards": [
    {"front": "Term / Question", "back": "Definition / Solution", "topic": "Subject"}
  ],
  "quiz": [
    {
      "question": "What is...?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctIndex": 0,
      "explanation": "Because...",
      "topic": "Subject"
    }
  ]
}
''';

    final parts = <Map<String, dynamic>>[];

    if (extractedTextContent != null && extractedTextContent.trim().isNotEmpty) {
      parts.add({
        'text': '$prompt\n\nDOCUMENT TEXT FROM "$fileName":\n\n$extractedTextContent',
      });
    } else if (rawBytes != null && mimeType != null) {
      final base64Data = base64Encode(rawBytes);
      parts.add({'text': '$prompt\n\nDocument File Name: $fileName'});
      parts.add({
        'inline_data': {
          'mime_type': mimeType,
          'data': base64Data,
        }
      });
    } else {
      parts.add({'text': '$prompt\n\nFile Name: $fileName'});
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': parts}
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.2,
        },
      }),
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = responseData['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response candidates returned by Gemini');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final partsList = content?['parts'] as List?;
    if (partsList == null || partsList.isEmpty) {
      throw Exception('Empty content parts returned');
    }

    final text = partsList.first['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Empty text response');
    }

    final cleanedJson = _cleanJsonString(text);
    final data = jsonDecode(cleanedJson) as Map<String, dynamic>;

    final transcription = data['transcription'] as String? ?? 'Transcribed notes from $fileName';
    final summary = data['summary'] as String? ?? 'Study notes summary for $fileName';
    final keyConcepts = (data['keyConcepts'] as List?)?.map((e) => e.toString()).toList() ?? [];

    final rawCards = (data['flashcards'] as List?) ?? [];
    final flashcards = rawCards.asMap().entries.map((entry) {
      final idx = entry.key;
      final map = entry.value as Map<String, dynamic>;
      return Flashcard(
        id: 'ocr-card-${DateTime.now().millisecondsSinceEpoch}-$idx',
        deckId: 'ocr-deck-${DateTime.now().millisecondsSinceEpoch}',
        front: map['front']?.toString() ?? 'Key Term $idx',
        back: map['back']?.toString() ?? 'Definition',
        topic: map['topic']?.toString() ?? 'Scanned Material',
      );
    }).toList();

    final rawQuiz = (data['quiz'] as List?) ?? [];
    final quizQuestions = rawQuiz.asMap().entries.map((entry) {
      final idx = entry.key;
      final map = entry.value as Map<String, dynamic>;
      final options = (map['options'] as List?)?.map((e) => e.toString()).toList() ??
          ['Option A', 'Option B', 'Option C', 'Option D'];
      return QuizQuestion(
        id: 'ocr-q-${DateTime.now().millisecondsSinceEpoch}-$idx',
        question: map['question']?.toString() ?? 'Question $idx',
        options: options,
        correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
        explanation: map['explanation']?.toString() ?? 'Explanation based on notes.',
        topic: map['topic']?.toString() ?? 'Scanned Material',
      );
    }).toList();

    return OcrScanResult(
      extractedText: transcription,
      summary: summary,
      keyConcepts: keyConcepts,
      generatedCards: flashcards,
      generatedQuiz: quizQuestions,
      imagePath: filePath,
      fileName: fileName,
    );
  }

  String _cleanJsonString(String raw) {
    String trimmed = raw.trim();
    if (trimmed.startsWith('```json')) {
      trimmed = trimmed.substring(7);
    } else if (trimmed.startsWith('```')) {
      trimmed = trimmed.substring(3);
    }
    if (trimmed.endsWith('```')) {
      trimmed = trimmed.substring(0, trimmed.length - 3);
    }
    return trimmed.trim();
  }

  OcrScanResult _buildResultFromExtractedText({
    required String text,
    required String fileName,
    required String filePath,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    final summary = lines.take(3).join(' ');
    final concepts = lines.take(5).toList();

    final flashcards = <Flashcard>[];
    for (int i = 0; i < lines.length && flashcards.length < 5; i += 2) {
      final front = lines[i];
      final back = (i + 1 < lines.length) ? lines[i + 1] : 'Key concept from document';
      flashcards.add(
        Flashcard(
          id: 'ocr-card-$now-$i',
          deckId: 'deck-$now',
          front: front,
          back: back,
          topic: 'Document Notes',
        ),
      );
    }

    final quiz = <QuizQuestion>[
      QuizQuestion(
        id: 'ocr-q-$now-1',
        question: 'What is the primary topic discussed in $fileName?',
        options: [
          lines.isNotEmpty ? lines.first : 'Primary Concept',
          'Unrelated Topic A',
          'Unrelated Topic B',
          'None of the above',
        ],
        correctIndex: 0,
        explanation: 'Derived directly from the extracted text of $fileName.',
        topic: 'Document Notes',
      ),
    ];

    return OcrScanResult(
      extractedText: text,
      summary: summary.isNotEmpty ? summary : 'Extracted from $fileName',
      keyConcepts: concepts,
      generatedCards: flashcards,
      generatedQuiz: quiz,
      imagePath: filePath,
      fileName: fileName,
    );
  }
}
