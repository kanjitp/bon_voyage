import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Users with ChangeNotifier {
  bool _onlyFriends;

  List<User> _users = [];

  List<User> get users {
    // to be changed later
    return _users;
  }

  List<User> get usersExcludingCurrentUser {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    return _users.where((user) => user.userId != currentUser.uid).toList();
  }

  Future<void> fetchUsers() async {
    // reset
    _users = [];
    final usersData =
        await FirebaseFirestore.instance.collection('users').get();
    print('fetchUsers - usersData downloaded');
    usersData.docs.forEach((user) {
      _users.add(User(
        name: user['name'],
        username: user['username'],
        userId: user.id,
        imageURL: user['imageUrl'],
        followers: user['followers'],
        followings: user['followings'],
        memories: user['posts'],
      ));
    });
    print(_users);
    print('fetchUsers - users updated');
  }
}
