import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ai_tutor_repository.dart';

// Chat message domain model
class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
  });

  ChatMessage copyWith({String? text}) {
    return ChatMessage(
      id: id,
      isUser: isUser,
      text: text ?? this.text,
      timestamp: timestamp,
    );
  }
}

final aiTutorRepositoryProvider = Provider((ref) => AiTutorRepository());

final chatMessagesProvider = NotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(() {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends Notifier<List<ChatMessage>> {
  bool isStreaming = false;

  @override
  List<ChatMessage> build() {
    return [];
  }

  Future<void> sendMessage(String text, {required String tone, required String language, String? topicContext}) async {
    if (text.trim().isEmpty || isStreaming) return;
    
    // Add User message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: true,
      text: text,
      timestamp: DateTime.now(),
    );
    
    // Add initial AI message
    final aiMsgId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
    final initialAiMsg = ChatMessage(
      id: aiMsgId,
      isUser: false,
      text: '',
      timestamp: DateTime.now(),
    );

    state = [...state, userMsg, initialAiMsg];
    isStreaming = true;

    try {
      final repository = ref.read(aiTutorRepositoryProvider);
      final stream = repository.streamChatResponse(
        prompt: text,
        tone: tone,
        language: language,
        topicContext: topicContext,
      );

      String accumulatedText = '';
      await for (final chunk in stream) {
        accumulatedText += chunk;
        
        // Update the last message in the state
        state = [
          ...state.sublist(0, state.length - 1),
          state.last.copyWith(text: accumulatedText),
        ];
      }
    } catch (e) {
       state = [
          ...state.sublist(0, state.length - 1),
          state.last.copyWith(text: "Error connecting to AI Tutor: \n${e.toString()}"),
       ];
    } finally {
      isStreaming = false;
    }
  }
}
