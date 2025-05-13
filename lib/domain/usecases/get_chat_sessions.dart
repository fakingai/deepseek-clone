import 'package:dartz/dartz.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class GetConversations implements UseCase<List<Conversation>, NoParams> {
  final ConversationRepository repository;

  GetConversations(this.repository);

  @override
  Future<Either<Failure, List<Conversation>>> call(NoParams params) async {
    return await repository.getConversations();
  }
}
