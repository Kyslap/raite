import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('Test Supabase Connection', (WidgetTester tester) async {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    expect(url.isNotEmpty, true, reason: 'SUPABASE_URL is missing in .env');
    expect(key.isNotEmpty, true, reason: 'SUPABASE_ANON_KEY is missing in .env');
    
    // Initialize Supabase
    await Supabase.initialize(url: url, anonKey: key);
    final client = Supabase.instance.client;
    
    // Attempt a simple health check query by selecting from a public table or just checking auth
    // Note: If you haven't created the 'classes' table yet, this might fail with a different error.
    // However, if the URL is correct, we will at least get a response from the server.
    try {
      // Just check if we can reach the health endpoint or a simple query
      final response = await client.from('classes').select().limit(1);
      print('Connection successful! Response: $response');
      expect(true, true);
    } catch (e) {
      if (e.toString().contains('relation "public.classes" does not exist')) {
        print('Connection successful! (But the classes table is missing. Did you run the SQL schema?)');
        expect(true, true);
      } else {
        print('Connection failed: $e');
        fail('Connection failed: $e');
      }
    }
  });
}
