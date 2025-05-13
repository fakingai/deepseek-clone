import 'package:dartz/dartz.dart';
import 'package:deepseek/domain/entities/conversation.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/conversation_repository.dart';

class ConversationParams {
  final String conversationId;
  
  const ConversationParams({required this.conversationId});
}

class GetConversationById implements UseCase<Conversation, ConversationParams> {
  final ConversationRepository repository;
  
  GetConversationById(this.repository);
  
  @override
  Future<Either<Failure, Conversation>> call(ConversationParams params) {
    return repository.getConversationById(params.conversationId);
  }
}
