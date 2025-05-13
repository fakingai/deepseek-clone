import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/conversation_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class DeleteConversation implements UseCase<bool, DeleteParams> {
  final ConversationRepository repository;

  DeleteConversation(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteParams params) async {
    return await repository.deleteConversation(params.id);
  }
}

class DeleteParams extends Equatable {
  final String id;

  const DeleteParams({required this.id});

  @override
  List<Object> get props => [id];
}
