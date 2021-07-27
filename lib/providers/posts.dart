import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:bon_voyage_a_new_experience/screens/menu_screen/chatroom_screen.dart';
import 'package:bon_voyage_a_new_experience/screens/menu_screen/feed_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Posts with ChangeNotifier {
  FeedMode currentMode = FeedMode.home;

  void setMode(FeedMode newMode) {
    currentMode = newMode;
  }
}
