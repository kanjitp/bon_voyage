import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chats with ChangeNotifier {
  // for earlier download
  List<Chat> _currentChats = [];

  List<Chat> get chats {
    return _currentChats;
  }

  Future<void> fetchChats() async {
    // reinitialised
    _currentChats = [];

    print('fetchChats - initialised');
    final currentUser = FirebaseAuth.instance.currentUser;
    print(currentUser.uid);

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    // containing userIds
    List<dynamic> chats = userData['chats'];

    chats.forEach(
      (chatmap) async {
        final someUserId = chatmap.keys.first;
        final someChatId = chatmap[someUserId];
        final chatRoomData = await FirebaseFirestore.instance
            .collection('chats')
            .doc(someChatId)
            .get();
        final otherUserData = await FirebaseFirestore.instance
            .collection('users')
            .doc(someUserId)
            .get();

        _currentChats.add(
          Chat(
            name: otherUserData['name'],
            chatId: someChatId,
            lastmessage: chatRoomData['lastmessage'],
            timestamp: chatRoomData['timestamp'],
            image: otherUserData['imageUrl'],
          ),
        );
      },
    );
    print('fetchChats - completed');
  }

  //
}
