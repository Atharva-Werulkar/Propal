part of 'chat_bloc_bloc.dart';

@immutable
sealed class ChatBlocEvent {}

class ChatGenerationEvent extends ChatBlocEvent {
  final String inputMessage;

  ChatGenerationEvent({required this.inputMessage});
}
