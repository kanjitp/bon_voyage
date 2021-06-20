import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController with ChangeNotifier {
  GoogleMapController googleMapController;

  void updateController(GoogleMapController newController) {
    this.googleMapController = newController;
  }
}
