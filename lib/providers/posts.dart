import 'package:flutter/material.dart';

import '../screens/menu_screen/feed_screen.dart';

class Posts with ChangeNotifier {
  FeedMode currentMode = FeedMode.home;

  void setMode(FeedMode newMode) {
    currentMode = newMode;
  }
}
