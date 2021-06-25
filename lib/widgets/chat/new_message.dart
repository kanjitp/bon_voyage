import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key key}) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final currentUser = await FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('chat').add(
      {
        'text': _enteredMessage,
        'timestamp': Timestamp.now(),
        'userId': currentUser.uid,
      },
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(8),
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
              padding: EdgeInsets.all(9),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).splashColor,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
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
        ));
  }
}
