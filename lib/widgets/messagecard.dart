import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:iconsax/iconsax.dart';

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isFromUser;

  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment:
            isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isFromUser)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFB3AAF2),
                child: IconButton(
                  icon: const Icon(Iconsax.user),
                  onPressed: () {},
                ),
              ),
            ) // Replace with your profile picture asset
          else
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Image.asset(
                'assets/star.png',
                width: 50,
                height: 50,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: isFromUser
                        ? const Color(0xFFB3AAF2)
                        : const Color(0xFF242A38),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: MarkdownBody(
                    softLineBreak: true,
                    styleSheet: MarkdownStyleSheet(
                      code: TextStyle(
                        decorationColor: isFromUser
                            ? const Color(0xFF242A38)
                            : const Color(0xFFD7D1F1),
                        color: isFromUser
                            ? const Color(0xFF242A38)
                            : const Color(0xFFD7D1F1),
                      ),
                      a: TextStyle(
                        color: isFromUser
                            ? const Color(0xFF242A38)
                            : const Color(0xFFD7D1F1),
                      ),
                      p: TextStyle(
                        color: isFromUser
                            ? const Color(0xFF242A38)
                            : const Color(0xFFD7D1F1),
                      ),
                    ),
                    styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                    selectable: true,
                    data: text,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
