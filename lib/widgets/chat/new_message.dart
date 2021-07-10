import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  Chat chat;

  NewMessage({this.chat, Key key}) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final currentUser = await FirebaseAuth.instance.currentUser;
    final timestamp = Timestamp.now();
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chat.chatId)
        .collection('messages')
        .add(
      {
        'text': _enteredMessage,
        'timestamp': timestamp,
        'userId': currentUser.uid,
      },
    );
    final chatRoomData = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chat.chatId)
        .get();
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chat.chatId)
        .set({
      'user1': chatRoomData['user1'],
      'user2': chatRoomData['user2'],
      'timestamp': timestamp,
      'lastmessage': _enteredMessage,
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SafeArea(
      child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          height: 55,
          child: Row(
            children: <Widget>[
              IconButton(
                iconSize: 30,
                onPressed: () {},
                icon: Icon(
                  Icons.add_circle,
                  color: Theme.of(context).splashColor,
                ),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).splashColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                      hintText: 'Message', border: InputBorder.none),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (input) {
                    setState(() {
                      _enteredMessage = input;
                    });
                  },
                ),
              )),
              IconButton(
                color: Theme.of(context).splashColor,
                onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
                icon: Icon(Icons.send),
              ),
            ],
          )),
    );
  }
}
