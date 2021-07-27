import 'dart:async';

import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:bon_voyage_a_new_experience/widgets/chat/update_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './message_bubble.dart';

class Messages extends StatefulWidget {
  final Chat chat;

  Messages({this.chat, Key key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chat.chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        final user = FirebaseAuth.instance.currentUser;
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final chatDocs = chatSnapshot.data.docs;
          // scroll to th ebottom at postframe rendered
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          });

          return ListView.builder(
            controller: _scrollController,
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              return chatDocs[index]['text'] == '${widget.chat.chatId} update'
                  ? UpdateBubble(
                      update_message: chatDocs[index]['update_message'],
                      key: ValueKey(chatDocs[index].id),
                    )
                  : MessageBubble(
                      chatDocs[index]['text'],
                      chatDocs[index]['userId'] == user.uid,
                      key: ValueKey(chatDocs[index].id),
                    );
            },
          );
        }
      },
    );
  }
}
