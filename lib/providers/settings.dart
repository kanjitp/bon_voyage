import 'package:flutter/foundation.dart';

class Settings with ChangeNotifier {
  bool enableMapButton = false;

  void setEnableMapButton(bool torf) {
    enableMapButton = torf;
  }
}
