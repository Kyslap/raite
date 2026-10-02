import 'dart:convert';
import 'package:http/http.dart' as http;
void main() async {
  final url = 'https://rrxfviqnslrsryhglnrv.supabase.co/rest/v1/ai_chat_logs';
  final anonKey = 'sb_publishable_ExgpwyVEUET0LsO0X2BmgA_5B71fSQR';
  final body = jsonEncode({'class_id': 'class-1', 'student_id': 'stu-101', 'prompt': 'test', 'response': 'test'});
  final res = await http.post(Uri.parse(url), headers: {'apikey': anonKey, 'Authorization': 'Bearer \$anonKey', 'Content-Type': 'application/json'}, body: body);
  print(res.body);
}
