import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:deepseek/data/models/message_model.dart';
import 'package:deepseek/domain/entities/message.dart';
import 'package:deepseek/core/services/logger_service.dart';
import 'package:deepseek/data/datasources/local_data_source.dart';

abstract class ChatRemoteDataSource {
  Stream<MessageModel> sendMessage(List<Message> messageHistory, {bool isDeepThinkingEnabled = false, bool isWebSearchEnabled = false});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio client;
  final LocalDataSource localDataSource; // Added localDataSource

  // OpenAI API endpoint
  final String _baseUrl = 'https://api.deepseek.com/chat/completions';

  final String defaultModel = 'deepseek-chat';
  final String deepThinkingModel = 'deepseek-reasoner'; // Example, replace with actual model name if different

  // You would need to provide an API key in a real implementation
  // In a production app, this should be stored securely
  ChatRemoteDataSourceImpl({required this.client, required this.localDataSource}) { // Added localDataSource
    // client.options.headers['Authorization'] = 'Bearer $_apiKey'; // API key will be set dynamically
    client.options.headers['Content-Type'] = 'application/json';
  }

  @override
  Stream<MessageModel> sendMessage(
      List<Message> messageHistory,
      {bool isDeepThinkingEnabled = false, 
      bool isWebSearchEnabled = false}) async* {
    
    final apiKey = await localDataSource.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      yield MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '请先在设置中设置API Key',
        role: MessageRole.system,
        timestamp: DateTime.now(),
      );
      return;
    }
    client.options.headers['Authorization'] = 'Bearer $apiKey'; // Set API key dynamically

    final List<Map<String, String>> messages = [];

    for (final message in messageHistory) {
        messages.add({
          'role': message.role.toString().split('.').last,
          'content': message.content,
        });
      }

    // Determine the model based on the flag
    final String modelToUse = isDeepThinkingEnabled ? deepThinkingModel : defaultModel;

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      'model': modelToUse,
      'messages': messages,
      'stream': true,
    };

    // Add web search parameter if enabled and API supports it
    // This is a hypothetical parameter. Replace with actual API parameter if available.
    // if (isWebSearchEnabled) {
    //   requestBody['web_search'] = true; 
    // }
    
    LoggerService().logInfo('Sending message to API. Model: $modelToUse, Message: ${messageHistory.last.content}');
    LoggerService().logInfo('Request body: $requestBody');

    try {
      final response = await client.post<ResponseBody>(
        _baseUrl,
        data: jsonEncode(requestBody), // Use the prepared request body
        options: Options(responseType: ResponseType.stream), // Important for SSE
      );

      if (response.statusCode == 200) {
        String accumulatedDeltaContent = "";
        final stream = response.data!.stream;

        await for (var chunkBytes in stream) {
          final chunk = utf8.decode(chunkBytes); // Decode bytes to string
          // SSE events are separated by double newlines
          final eventStrings = chunk.split('\n\n').where((s) => s.isNotEmpty).toList();

          for (final eventString in eventStrings) {
            if (eventString.startsWith('data: ')) {
              final jsonDataString = eventString.substring('data: '.length);
              if (jsonDataString == '[DONE]') {
                // If there's any accumulated content before DONE, yield it as the final part.
                if (accumulatedDeltaContent.isNotEmpty) {
                     yield MessageModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        content: accumulatedDeltaContent,
                        role: MessageRole.assistant,
                        timestamp: DateTime.now(),
                      );
                      accumulatedDeltaContent = ""; // Reset for next potential full message
                }
                LoggerService().logInfo('SSE stream finished.');
                return; // End of stream
              }

              try {
                final jsonResponse = jsonDecode(jsonDataString);
                if (jsonResponse['choices'] != null && jsonResponse['choices'].isNotEmpty) {
                  final delta = jsonResponse['choices'][0]['delta'];
                  if (delta != null && delta['content'] != null) {
                    final deltaContent = delta['content'] as String;
                    accumulatedDeltaContent += deltaContent;
                    // Yield intermediate message parts
                    yield MessageModel(
                      id: "${DateTime.now().millisecondsSinceEpoch}_partial", // Mark as partial
                      content: accumulatedDeltaContent, // Send accumulated content so far
                      role: MessageRole.assistant,
                      timestamp: DateTime.now(),
                      isPartial: true,
                    );
                  }
                }
              } catch (e, s) {
                LoggerService().logError('Error parsing SSE JSON: $jsonDataString', error: e, stackTrace: s);
                // Potentially yield an error message or handle differently
              }
            }
          }
        }
        // After the loop, if there's any remaining content, yield it as the final message.
        // This handles cases where the stream ends without a [DONE] marker but has content.
        if (accumulatedDeltaContent.isNotEmpty) {
            yield MessageModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: accumulatedDeltaContent,
              role: MessageRole.assistant,
              timestamp: DateTime.now(),
            );
        }

      } else {
        final errorBody = await utf8.decodeStream(response.data!.stream);
        LoggerService().logError(
          'API error response for SSE',
          error: 'Status code: ${response.statusCode}, Response: $errorBody',
        );
        yield MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Error: ${response.statusCode} - Failed to connect to API. Details: $errorBody',
          role: MessageRole.system, // Or assistant, depending on how you want to show errors
          timestamp: DateTime.now(),
        );
      }
    } catch (e, s) {
      LoggerService().logError(
        'Network error during SSE sendMessage',
        error: e,
        stackTrace: s,
      );
      yield MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Network error: $e',
        role: MessageRole.system,
        timestamp: DateTime.now(),
      );
    }
  }
}
