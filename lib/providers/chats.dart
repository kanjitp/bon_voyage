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

    List<dynamic> chatIds = userData['chats'];

    chatIds.forEach(
      (chatId) async {
        final chatRoomData = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .get();
        final user1Id = chatRoomData['user1'];
        final user2Id = chatRoomData['user2'];
        final otherUserId = user1Id == currentUser.uid ? user2Id : user1Id;
        final otherUserData = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();

        _currentChats.add(
          Chat(
            name: otherUserData['name'],
            chatId: chatId,
            image: otherUserData['imageUrl'],
          ),
        );
      },
    );
    print('fetchChats - completed');
  }

  //
}
