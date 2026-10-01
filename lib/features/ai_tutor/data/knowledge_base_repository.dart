import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class KnowledgeBaseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> uploadClassMaterial(String classId, File file) async {
    String originalFileName = file.path.split('/').last;
    final extension = originalFileName.split('.').last.toLowerCase();
    
    if (extension != 'txt' && extension != 'md' && extension != 'csv' && extension != 'pdf') {
      throw Exception('Currently only .pdf, .txt, .md, and .csv files are supported.');
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // 1. Upload Original File to Storage
    final originalStoragePath = 'materials/$classId/${DateTime.now().millisecondsSinceEpoch}_$originalFileName';
    await _supabase.storage.from('class_materials').upload(originalStoragePath, file);

    String? rawTextStoragePath;

    // 2. Client-Side Extraction for PDFs
    if (extension == 'pdf') {
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();
      
      if (text.trim().isEmpty) {
        throw Exception('Could not extract any text from the PDF. It might be scanned or image-based.');
      }
      
      // Save the extracted text to a temporary .txt file
      final tempDir = Directory.systemTemp;
      final txtFileName = originalFileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '.txt');
      final fileToUpload = File('${tempDir.path}/$txtFileName');
      await fileToUpload.writeAsString(text);

      rawTextStoragePath = 'materials/$classId/${DateTime.now().millisecondsSinceEpoch}_$txtFileName';
      await _supabase.storage.from('class_materials').upload(rawTextStoragePath, fileToUpload);
    }

    // 3. Insert into class_documents
    final docData = await _supabase.from('class_documents').insert({
      'class_id': classId,
      'title': originalFileName,
      'file_url': originalStoragePath,
      if (rawTextStoragePath != null) 'raw_text_url': rawTextStoragePath,
      'uploaded_by': userId,
    }).select().single();

    final docId = docData['id'] as String;

    // 4. Trigger Edge Function to process and embed
    final response = await _supabase.functions.invoke(
      'process_document',
      body: {
        'document_id': docId,
        'class_id': classId,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to process document: ${response.data}');
    }
  }

  Future<List<Map<String, dynamic>>> getClassDocuments(String classId) async {
    final data = await _supabase
        .from('class_documents')
        .select()
        .eq('class_id', classId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
