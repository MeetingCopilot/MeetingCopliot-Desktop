import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:meeting_copilot_desktop/entity/conversation.dart';

class ConversationBlock extends StatelessWidget {
  final Conversation _conversation;

  const ConversationBlock({
    super.key,
    required Conversation conversation,
  }) : _conversation = conversation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.blue[100],
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(300, 4, 8, 4),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: MarkdownBody(
                data: _conversation.question,
              ),
            ),
          ),
        ),
        Card(
          color: Colors.grey[100],
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(8, 4, 300, 4),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: MarkdownBody(
                data: _conversation.answer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
