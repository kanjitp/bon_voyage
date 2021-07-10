import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../widgets/chat/new_message.dart';

import '../../../widgets/chat/messages.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen(this.chat);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
      return;
    });
    fbm.subscribeToTopic('chat');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: widget.chat.image == null
                  ? AssetImage('./assets/images/dummy_user.png')
                  : NetworkImage(widget.chat.image),
            ),
            SizedBox(
              width: mediaQuery.size.width * 0.02,
            ),
            Column(
              children: <Widget>[
                Text(
                  widget.chat.name,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Active 3m ago",
                  style: TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Messages(chat: widget.chat),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey))),
              child: NewMessage(chat: widget.chat),
            ),
          ],
        ),
      ),
    );
  }
}
