import 'package:dartz/dartz.dart';
import '../entities/conversation.dart';
import '../../core/error/failures.dart';

abstract class ConversationRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();
  Future<Either<Failure, Conversation>> createConversation();
  Future<Either<Failure, Conversation>> renameConversation(String id, String newTitle);
  Future<Either<Failure, bool>> deleteConversation(String id);
  Future<Either<Failure, Conversation>> getConversationById(String id);
  Future<Either<Failure, Conversation>> updateConversation(Conversation conversation);
  Future<Either<Failure, void>> deleteAllConversations();
}
