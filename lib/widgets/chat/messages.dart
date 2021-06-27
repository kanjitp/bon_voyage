import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './message_bubble.dart';

class Messages extends StatelessWidget {
  Chat chat;

  Messages({this.chat, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chat.chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        final user = FirebaseAuth.instance.currentUser;
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final chatDocs = chatSnapshot.data.docs;
          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) => MessageBubble(
              chatDocs[index]['text'],
              chatDocs[index]['userId'] == user.uid,
              key: ValueKey(chatDocs[index].id),
            ),
          );
        }
      },
    );
  }
}
