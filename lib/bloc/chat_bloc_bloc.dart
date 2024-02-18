import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:propal/models/chat_model.dart';
import 'package:propal/repos/chat_repo.dart';

part 'chat_bloc_event.dart';
part 'chat_bloc_state.dart';

class ChatBlocBloc extends Bloc<ChatBlocEvent, ChatBlocState> {
  ChatBlocBloc() : super(ChatSuccessState(messages: [])) {
    on<ChatGenerationEvent>(chatGenerationEvent);
  }
  List<ChatMessageModel> message = [];
  bool generating = false;

  FutureOr<void> chatGenerationEvent(
      ChatGenerationEvent event, Emitter<ChatBlocState> emit) async {
    message.add(ChatMessageModel(
        role: "user", parts: [ChatPartModel(text: event.inputMessage)]));
    emit(ChatSuccessState(messages: message));

    generating = true;

    String generatedtext = await ChatRepo.chatGenerationRepo(message);

    if (generatedtext.length > 0) {
      message.add(ChatMessageModel(
          role: "model", parts: [ChatPartModel(text: generatedtext)]));
      emit(ChatSuccessState(messages: message));
    } else {
      emit(ChatSuccessState(messages: message));
    }
    generating = false;
  }
}
