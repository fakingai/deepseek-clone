import 'package:deepseek/domain/entities/message.dart';

abstract class ChatRepository {
  Stream<Message> sendMessage(List<Message> messageHistory, {bool isDeepThinkingEnabled = false, bool isWebSearchEnabled = false});
}
