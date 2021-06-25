import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CurrentUser with ChangeNotifier {
  String username;
  String name;
  String userId;
  String bio;
  String imageUrl;
  DateTime dateOfBirth;
  bool isVisible;
  double maxDistanceVisible;
  Position lastLocation;

  CurrentUser();

  Future<void> update() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    username = userData['username'];
    name = userData['name'];
    imageUrl = userData['imageUrl'];
    print('user - update successful');
  }

  void setLocation(Position loc) {
    lastLocation = loc;
  }
}
