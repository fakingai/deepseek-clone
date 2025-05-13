import 'package:dartz/dartz.dart';
import 'package:deepseek/core/error/failures.dart';
import 'package:deepseek/core/usecases/usecase.dart';
import 'package:deepseek/domain/repositories/conversation_repository.dart';

class DeleteAllConversations implements UseCase<void, NoParams> {
  final ConversationRepository repository;

  DeleteAllConversations(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAllConversations();
  }
}
