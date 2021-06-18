import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BonVoyageMap extends StatefulWidget {
  @override
  _BonVoyageMapState createState() => _BonVoyageMapState();
}

class _BonVoyageMapState extends State<BonVoyageMap> {
  static final _initialCameraPosition =
      CameraPosition(target: LatLng(1.294821, 103.784438), zoom: 18.0);

  GoogleMapController _googleMapController;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _googleMapController = controller,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(
          Icons.center_focus_strong,
        ),
      ),
    );
  }
}
