import 'dart:async';
import 'package:deepseek/data/datasources/chat_remote_data_source.dart';
import 'package:deepseek/domain/entities/message.dart';
import 'package:deepseek/domain/repositories/chat_repository.dart';
import 'package:deepseek/core/network/network_info.dart';
import 'package:deepseek/core/services/logger_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<Message> sendMessage(List<Message>messageHistory, 
      {bool isDeepThinkingEnabled = false, 
      bool isWebSearchEnabled = false}) async* {
    LoggerService().logInfo('Sending message: ${messageHistory.last.content} with history: ${messageHistory.length } items, DeepThink: $isDeepThinkingEnabled, WebSearch: $isWebSearchEnabled');
    if (await networkInfo.isConnected) {
      try {
        yield* remoteDataSource.sendMessage(
            messageHistory, 
            isDeepThinkingEnabled: isDeepThinkingEnabled, // Pass flag
            isWebSearchEnabled: isWebSearchEnabled); // Pass flag
      } catch (e, s) {
        LoggerService().logError('Failed to send message via remote data source', error: e, stackTrace: s);
        yield Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Error: Failed to send message. $e',
          role: MessageRole.system,
          timestamp: DateTime.now(),
        );
      }
    } else {
      LoggerService().logWarning('No internet connection when trying to send message.');
      yield Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Error: No internet connection.',
        role: MessageRole.system,
        timestamp: DateTime.now(),
      );
    }
  }
}
