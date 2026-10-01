import 'dart:io';
import 'dart:convert';

void main() async {
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String url = '';
  String key = '';
  
  for (var line in lines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1].trim();
    if (line.startsWith('SUPABASE_ANON_KEY=')) key = line.split('=')[1].trim();
  }
  
  print('Testing connection to: ' + url);
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url + '/rest/v1/classes?select=*&limit=1'));
    request.headers.add('apikey', key);
    request.headers.add('Authorization', 'Bearer ' + key);
    
    final response = await request.close();
    
    print('Status Code: ' + response.statusCode.toString());
    final responseBody = await response.transform(utf8.decoder).join();
    print('Response: ' + responseBody);

    if (response.statusCode == 200) {
       print('Successfully reached the server AND the table exists!');
    }
  } catch (e) {
    print('Failed to connect: ' + e.toString());
  }
  exit(0);
}
