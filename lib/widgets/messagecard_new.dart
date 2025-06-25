import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    try {
      // Ensure text is not null or empty
      final textToCopy = text.trim();
      if (textToCopy.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No text to copy'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      await Clipboard.setData(ClipboardData(text: textToCopy));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFFB3AAF2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy text: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Column(
        crossAxisAlignment:
            isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Avatar
          if (isFromUser)
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFB3AAF2),
                child: Icon(Iconsax.user),
              ),
            )
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

          // Message bubble
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                    maxHeight: 1000, // Prevent infinite height
                  ),
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
                  child: SingleChildScrollView(
                    child: MarkdownBody(
                      softLineBreak: true,
                      styleSheet: MarkdownStyleSheet(
                        blockquote: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                        checkbox: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                        h1: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                        del: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                        em: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                        listBullet: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                        strong: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                        tableBody: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                        code: TextStyle(
                          decorationColor: isFromUser
                              ? const Color(0xFF242A38)
                              : const Color(0xFFFFFFFF),
                          color: isFromUser
                              ? const Color(0xFF242A38)
                              : const Color(0xFFFFFFFF),
                        ),
                        a: TextStyle(
                          color: isFromUser
                              ? const Color(0xFF242A38)
                              : const Color(0xFFFFFFFF),
                        ),
                        p: TextStyle(
                          color: isFromUser
                              ? const Color(0xFF242A38)
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                      styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                      selectable:
                          false, // Disable selectable to prevent crashes
                      data: text.isNotEmpty ? text : ' ',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Copy button for AI responses
          if (!isFromUser)
            Padding(
              padding: const EdgeInsets.only(left: 60.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _copyToClipboard(context, text),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A4356),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF5A6B7D),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.copy,
                              size: 14,
                              color: Color(0xFFB3AAF2),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                color: Color(0xFFB3AAF2),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
