import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:propal/bloc/chat_bloc_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatBlocBloc chatBloc = ChatBlocBloc();
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeData.dark().primaryColor,
        title: const Text('Propal'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            size: 30,
          ),
          onPressed: () {},
        ),
        automaticallyImplyLeading: true,
        actions: [
          //profile picture
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFB3AAF2),
              child: IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
      body: BlocConsumer<ChatBlocBloc, ChatBlocState>(
        bloc: chatBloc,
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case ChatBlocInitial:
              return const Center(
                child: Text("Initial"),
              );
            case ChatSuccessState:
              final messages = (state as ChatSuccessState).messages;

              return Container(
                height: double.maxFinite,
                width: double.maxFinite,
                color: ThemeData.dark().scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment: messages[index].role == "user"
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (messages[index].role == "user")
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: const Color(0xFFB3AAF2),
                                    child: IconButton(
                                      icon: const Icon(Icons.person),
                                      onPressed: () {},
                                    ),
                                  ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                        color: messages[index].role == "user"
                                            ? const Color(0xFFB3AAF2)
                                            : const Color(0xFF242A38),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      children: messages[index]
                                          .parts
                                          .map((e) => SizedBox(
                                                child: Text(
                                                  textAlign:
                                                      messages[index].role ==
                                                              "model"
                                                          ? TextAlign.start
                                                          : TextAlign.end,
                                                  softWrap: true,
                                                  overflow: TextOverflow.clip,
                                                  e.text,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),
                    ),
                    if (chatBloc.generating)
                      Lottie.asset(
                        "assets/loader.json",
                        height: 150,
                        width: 150,
                        repeat: true,
                      ),
                    Container(
                      color: ThemeData.dark().primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: textEditingController,
                              style: const TextStyle(
                                  color: Color(0xFFD7D1F1), fontSize: 20),
                              cursorColor: const Color(0xFFB3AAF2),
                              decoration: InputDecoration(
                                  hintText: "Ask Something to Pal",
                                  hintStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFD7D1F1),
                                  ),
                                  filled: true,
                                  fillColor: ThemeData.dark().primaryColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(100),
                                  )),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              if (textEditingController.text.isNotEmpty) {
                                final text = textEditingController.text;
                                textEditingController.clear();
                                chatBloc.add(
                                    ChatGenerationEvent(inputMessage: text));
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFFD7D1F1),
                              radius: 32,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFFB3AAF2),
                                child: Icon(Icons.send,
                                    size: 30,
                                    color: ThemeData.dark().primaryColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );

            default:
              return const Center(
                child: Text("Default"),
              );
          }
        },
      ),
    );
  }
}
