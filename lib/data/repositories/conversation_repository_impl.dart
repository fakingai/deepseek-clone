import 'package:dartz/dartz.dart';
import 'package:deepseek/data/datasources/conversation_local_data_source.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../models/conversation_model.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationLocalDataSource localDataSource;

  ConversationRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final sessions = await localDataSource.getConversations();
      return Right(sessions);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation() async {
    try {
      final id = await localDataSource.createNewConversation();
      final session = await localDataSource.getConversation(id);
      if (session == null) {
        return Left(CacheFailure());
      }
      return Right(session);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Conversation>> renameConversation(String id, String newTitle) async {
    try {
      // Get the current conversation
      final currentConversation = await localDataSource.getConversation(id);
      
      if (currentConversation == null) {
        return Left(CacheFailure());
      }
      
      // Create a new conversation model with the updated title
      final updatedConversation = ConversationModel(
        id: currentConversation.id,
        title: newTitle,
        messages: currentConversation.messages,
        createdAt: currentConversation.createdAt,
        updatedAt: DateTime.now(),
      );
      
      // Save the updated conversation
      await localDataSource.saveConversation(updatedConversation);
      
      // Return the updated conversation
      return Right(updatedConversation);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteConversation(String id) async {
    try {
      await localDataSource.deleteConversation(id);
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversationById(String id) async {
    try {
      final session = await localDataSource.getConversation(id);
      if (session == null) {
        return Left(CacheFailure());
      }
      return Right(session);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Conversation>> updateConversation(Conversation conversation) async {
    try {
      final model = ConversationModel.fromEntity(conversation);
      await localDataSource.saveConversation(model);
      
      // Fetch the updated conversation to return it
      final updatedSession = await localDataSource.getConversation(model.id);
      if (updatedSession == null) {
        return Left(CacheFailure());
      }
      return Right(updatedSession);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllConversations() async {
    try {
      await localDataSource.deleteAllConversations();
      return const Right(null); // Or Right(unit) if you have dartz unit imported
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
