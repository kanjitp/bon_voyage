import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  static final routeName = '/chat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
      ),
    );
  }
}
