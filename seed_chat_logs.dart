import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://rrxfviqnslrsryhglnrv.supabase.co/rest/v1/ai_chat_logs';
  final anonKey = 'sb_publishable_ExgpwyVEUET0LsO0X2BmgA_5B71fSQR';
  
  final questions = [
    "Can you explain the chain rule for backpropagation?",
    "I'm confused about matrix derivatives in neural networks.",
    "How does the chain rule apply to multi-variable functions?",
    "Could you break down backpropagation step by step?",
    "Why do we need surface normal orientation for Stokes Theorem?",
    "What is the physical intuition behind Stokes Theorem?",
    "I don't understand how to choose the normal vector orientation.",
    "Can you show an example of boundary integrals using Stokes theorem?",
    "How do eigenvalues relate to matrix diagonalization?",
    "Why can't all matrices be diagonalized?",
    "Can you explain the characteristic equation for eigenvalues?",
    "What's the difference between eigenvectors and eigenvalues visually?",
    "How does gradient descent differ from momentum optimizer?",
    "What is learning rate in gradient descent?",
    "Why does gradient descent get stuck in local minima?",
    "I'm having trouble with the matrix calculus homework.",
    "Could you review the boundary conditions for the surface integral?",
    "What happens if the matrix is defective and lacks independent eigenvectors?",
  ];

  for (var q in questions) {
    final body = jsonEncode({
      'class_id': 'class-1',
      'student_id': 'stu-101',
      'prompt': q,
      'response': 'This is a simulated AI response for the question.',
    });
    
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal'
        },
        body: body,
      );
      print('Inserted: ${res.statusCode}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
