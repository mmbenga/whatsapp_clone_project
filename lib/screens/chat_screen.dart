import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.chatName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: Text(chatName),
      ),
      body: Center(
        child: Text('Chat with $chatName'),
      ),
    );
  }
}