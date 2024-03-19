import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ConversationBlock extends StatelessWidget {
  final String _textBody;

  final bool _isMe;
  final EdgeInsets geminiEdge = const EdgeInsets.fromLTRB(8, 4, 300, 4);

  final EdgeInsets userEdge = const EdgeInsets.fromLTRB(300, 4, 8, 4);

  const ConversationBlock({
    super.key,
    required String textBody,
    required bool isMe,
  })  : _textBody = textBody,
        _isMe = isMe;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isMe ? Colors.blue[100] : Colors.grey[100],
      elevation: 0,
      margin: _isMe ? userEdge : geminiEdge,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: MarkdownBody(
            data: _textBody,
          ),
        ),
      ),
    );
  }
}
