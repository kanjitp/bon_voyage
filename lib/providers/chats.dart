import 'package:flutter/material.dart';

import '../screens/menu_screen/chatroom_screen.dart';

class Chats with ChangeNotifier {
  ChatRoomMode currentMode = ChatRoomMode.recent;

  void setMode(ChatRoomMode newMode) {
    currentMode = newMode;
  }
}
