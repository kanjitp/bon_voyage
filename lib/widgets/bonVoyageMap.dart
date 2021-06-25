import 'dart:async';
import 'dart:typed_data';

import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/mapController.dart';
import '../providers/user_location.dart';
import '../providers/tilt_level.dart';
import './googlemap/currentUserLocBtn.dart';
import './googlemap/tiltBtn.dart';
import './googlemap/maneuverBtn.dart';

class BonVoyageMap extends StatefulWidget {
  @override
  _BonVoyageMapState createState() => _BonVoyageMapState();
}

class _BonVoyageMapState extends State<BonVoyageMap> {
  StreamSubscription _locationSubscription; // Stream of userlocation
  double calibration = -55; // calibration for heading of the image
  double postRadius = 90;

  GoogleMapController _googleMapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load('./assets/images/user_pin.png');
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(Position newLocationData, Uint8List imageData) {
    // print('updateMarkerAndcircle: Called');
    LatLng latlng = LatLng(newLocationData.latitude, newLocationData.longitude);

    setState(() {
      Provider.of<UserLocation>(context, listen: false).updateUserMarker(
        Marker(
          markerId: MarkerId("user"),
          position: latlng,
          rotation: newLocationData.heading + calibration,
          draggable: false,
          // put the marker infront
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData),
        ),
      );
      Provider.of<UserLocation>(context, listen: false).updatepostArea(
        Circle(
          circleId: CircleId("user"),
          radius: postRadius,
          // put the circle in the back
          zIndex: 1,
          strokeColor: Colors.amber,
          center: latlng,
          fillColor: Colors.amber.withOpacity(0.5),
        ),
      );
    });
    print('updateMarkerAndCircle: Location Updated');
  }

  void getCurrentLocation() async {
    try {
      // UnsignedIntegerList
      Uint8List imageData = await getMarker();
      // print('getCurrentLocation: imageData-$imageData');
      var userLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('getCurrentLocation: -location$userLocation');

      Provider.of<UserLocation>(context, listen: false)
          .updateUserLocation(userLocation);
      updateMarkerAndCircle(userLocation, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(userLocation.latitude, userLocation.longitude),
            tilt: Provider.of<TiltLevel>(context, listen: false).tiltLevel,
            zoom: await _googleMapController.getZoomLevel(),
            bearing: userLocation.heading,
          ),
        ),
      );

      _locationSubscription =
          Geolocator.getPositionStream().listen((newLocationData) async {
        Provider.of<UserLocation>(context, listen: false)
            .updateUserLocation(newLocationData);
        _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  LatLng(newLocationData.latitude, newLocationData.longitude),
              tilt: Provider.of<TiltLevel>(context, listen: false).tiltLevel,
              zoom: await _googleMapController.getZoomLevel(),
              bearing: newLocationData.heading,
            ),
          ),
        );
        updateMarkerAndCircle(newLocationData, imageData);
      });
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        debugPrint("Permission Denied: Please try again");
      }
    }
  }

  PadButtonPressedCallback padButtonPressedCallback(
      int buttonIndex, Gestures gesture) {}

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var initialUserLocation =
        Provider.of<UserLocation>(context, listen: false).userLocation;
    var userMarker =
        Provider.of<UserLocation>(context, listen: false).userMarker;
    var postArea = Provider.of<UserLocation>(context, listen: false).postArea;

    return Scaffold(
      body: Stack(children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          compassEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: CameraPosition(
            target: initialUserLocation == null
                ? LatLng(1.296377, 103.776430)
                : LatLng(initialUserLocation.latitude,
                    initialUserLocation.longitude),
            tilt: Provider.of<TiltLevel>(context, listen: false).tiltLevel,
            zoom: 18,
            bearing:
                initialUserLocation == null ? 0 : initialUserLocation.heading,
          ),
          markers: {if (userMarker != null) userMarker},
          circles: {
            if (postArea != null) postArea,
          },
          onMapCreated: (controller) {
            _googleMapController = controller;
            Provider.of<MapController>(context, listen: false)
                .updateController(controller);
          },
        ),
        Align(alignment: Alignment.bottomLeft, child: TiltButton()),
        Positioned(
          top: mediaQuery.size.height * 4 / 5,
          left: mediaQuery.size.width / 3,
          child: ManeuverButton(
            size: mediaQuery.size.width / 3,
            onDirectionChange: () {},
          ),
        ),
        Align(
            alignment: Alignment.bottomRight,
            child: CurrentUserLocationButton(getCurrentLocation)),
      ]),
    );
  }
}
