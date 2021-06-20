import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation with ChangeNotifier {
  Position userLocation;
  Marker userMarker;
  Circle postArea;

  void updateUserLocation(Position newPos) {
    this.userLocation = newPos;
  }

  void updateUserMarker(Marker newMarker) {
    this.userMarker = newMarker;
  }

  void updatepostArea(Circle postArea) {
    this.postArea = postArea;
  }
}
