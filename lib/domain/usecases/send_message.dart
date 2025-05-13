import 'dart:async';
import 'package:deepseek/domain/entities/message.dart';
import 'package:deepseek/domain/repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Stream<Message> call( 
      List<Message> messageHistory, 
      {bool isDeepThinkingEnabled = false, 
      bool isWebSearchEnabled = false}) {
    return repository.sendMessage(messageHistory, 
        isDeepThinkingEnabled: isDeepThinkingEnabled, 
        isWebSearchEnabled: isWebSearchEnabled);
  }
}
