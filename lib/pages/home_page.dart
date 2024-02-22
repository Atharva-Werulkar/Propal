import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:propal/utils/constants.dart';
import 'package:propal/widgets/messagecard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: api_key,
    );
    _chat = _model.startChat();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: "Ask Something to Pal..",
      hintStyle: const TextStyle(
        color: Color(0xFFD7D1F1),
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF242A38),
        title: const Text('Propal'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Iconsax.menu_1,
            size: 30,
          ),
          onPressed: () {},
        ),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: const Color(0xFF1B1F2B),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: api_key.isNotEmpty
                  ? ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: _scrollController,
                      itemBuilder: (context, idx) {
                        var content = _chat.history.toList()[idx];

                        var text = content.parts
                            .whereType<TextPart>()
                            .map<String>((e) => e.text)
                            .join('');

                        return MessageWidget(
                          text: text,
                          isFromUser: content.role == 'user',
                        );
                      },
                      itemCount: _chat.history.length,
                    )
                  : ListView(
                      children: const [
                        Text('No API key found. Please provide an API Key.'),
                      ],
                    ),
            ),
            if (_loading)
              Lottie.asset('assets/loader.json', height: 100, width: 100),
            Container(
              color: const Color(0xFF242A38),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        minLines: 1, // Minimum 3 lines
                        maxLines: 5, // Up to 5 lines
                        style: const TextStyle(
                            color: Color(0xFFD7D1F1), fontSize: 20),
                        cursorColor: const Color(0xFFB3AAF2),
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        decoration: textFieldDecoration,
                        controller: _textController,
                        onSubmitted: (String value) {
                          _sendChatMessage(value);
                        },
                      ),
                    ),
                    const SizedBox.square(
                      dimension: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        onPressed: () async {
                          _sendChatMessage(_textController.text);
                          _textController.clear();
                        },
                        icon: Icon(Iconsax.send_2,
                            color: Theme.of(context).colorScheme.primary,
                            size: 35),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      var response = await _chat.sendMessage(
        Content.text(message),
      );

      var text = response.text;

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Something went wrong',
            style: TextStyle(
              color: Color(0xFFD7D1F1),
            ),
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              message,
              style: const TextStyle(
                color: Color(0xFFD7D1F1),
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFFD7D1F1),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
