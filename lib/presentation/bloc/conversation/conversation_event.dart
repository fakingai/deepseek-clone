import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class GetConversationsEvent extends ConversationEvent {}

class CreateConversationEvent extends ConversationEvent {
  final String title;

  const CreateConversationEvent({required this.title});

  @override
  List<Object> get props => [title];
}

class RenameConversationEvent extends ConversationEvent {
  final String id;
  final String newTitle;

  const RenameConversationEvent({required this.id, required this.newTitle});

  @override
  List<Object> get props => [id, newTitle];
}

class DeleteConversationEvent extends ConversationEvent {
  final String id;

  const DeleteConversationEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class SelectConversationEvent extends ConversationEvent {
  final String id;

  const SelectConversationEvent({required this.id});

  @override
  List<Object> get props => [id];
}
