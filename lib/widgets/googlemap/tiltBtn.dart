import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/mapController.dart';
import '../../providers/tilt_level.dart';

class TiltButton extends StatefulWidget {
  @override
  _TiltButtonState createState() => _TiltButtonState();
}

class _TiltButtonState extends State<TiltButton> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var tiltData = Provider.of<TiltLevel>(context);
    // finish database first
    return Container(
      margin: EdgeInsets.all(20),
      child: FloatingActionButton(
        heroTag: 'planeBtn',
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () async {
          var _googleMapController =
              Provider.of<MapController>(context, listen: false)
                  .googleMapController;
          if (!tiltData.isTilted) {
            tiltData.updateTiltLevel(100);
            _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: await _googleMapController.getLatLng(
                    ScreenCoordinate(
                        x: mediaQuery.size.width ~/ 2,
                        y: mediaQuery.size.height ~/ 2),
                  ),
                  zoom: await _googleMapController.getZoomLevel(),
                  tilt: tiltData.tiltLevel),
            ));
          } else {
            tiltData.updateTiltLevel(0);

            _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: await _googleMapController.getLatLng(
                    ScreenCoordinate(
                        x: mediaQuery.size.width ~/ 2,
                        y: mediaQuery.size.height ~/ 2),
                  ),
                  zoom: await _googleMapController.getZoomLevel(),
                  tilt: tiltData.tiltLevel),
            ));
          }
          setState(() {
            tiltData.toggleIsTilted();
          });
        },
        child: !tiltData.isTilted
            ? Icon(Icons.flight_takeoff)
            : Icon(
                Icons.flight_land,
              ),
      ),
    );
  }
}
