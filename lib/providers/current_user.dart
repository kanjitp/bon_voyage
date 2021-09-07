import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import '../models/user_presence.dart';

import '../models/user.dart';

class CurrentUser with ChangeNotifier {
  User user;

  CurrentUser();

  Future<void> update() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    user = User(
      username: userData['username'],
      userId: currentUser.uid,
      name: userData['name'],
      imageURL: userData['imageUrl'],
      chats: userData['chats'],
      followers: userData['followers'],
      followings: userData['followings'],
      memories: userData['posts'],
    );
    await UserPresence.rtdbAndLocalFsPresence();
    print('CurrentUser - updated');
  }
}
