import 'package:flutter/material.dart';

class TiltLevel with ChangeNotifier {
  double tiltLevel = 0;
  bool isTilted = false;

  void updateTiltLevel(double newTiltLevel) {
    this.tiltLevel = newTiltLevel;
  }

  void toggleIsTilted() {
    this.isTilted = !this.isTilted;
  }
}
