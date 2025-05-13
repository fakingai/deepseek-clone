import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class RenameConversation implements UseCase<Conversation, RenameParams> {
  final ConversationRepository repository;

  RenameConversation(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(RenameParams params) async {
    return await repository.renameConversation(params.id, params.newTitle);
  }
}

class RenameParams extends Equatable {
  final String id;
  final String newTitle;

  const RenameParams({required this.id, required this.newTitle});

  @override
  List<Object> get props => [id, newTitle];
}
