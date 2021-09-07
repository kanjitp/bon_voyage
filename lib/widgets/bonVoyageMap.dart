import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:control_pad/control_pad.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/markers_notifier.dart';
import '../providers/settings.dart';
import '../providers/mapController.dart';
import '../providers/user_location.dart';
import '../providers/tilt_level.dart';

import './googlemap/currentUserLocBtn.dart';
import './googlemap/tiltBtn.dart';
import './googlemap/maneuverBtn.dart';

import '../logics/hero_dialog_route.dart';

import '../widgets/googlemap/post_popup_card.dart';

class BonVoyageMap extends StatefulWidget {
  final bool allowPost;
  final LatLng initialCoordinate;
  bool forceNavigation = false;

  BonVoyageMap({
    this.allowPost = true,
    this.initialCoordinate,
    this.forceNavigation = false,
  });

  @override
  _BonVoyageMapState createState() => _BonVoyageMapState();
}

class _BonVoyageMapState extends State<BonVoyageMap> {
  StreamSubscription _locationSubscription; // Stream of userlocation
  double calibration = -55; // calibration for heading of the image
  double postRadius = 90; // in metre
  LatLng currentCoordinate;

  GoogleMapController _googleMapController;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    currentCoordinate = widget.initialCoordinate == null
        ? LatLng(1.296377, 103.776430)
        : widget.initialCoordinate;

    super.initState();
  }

  Marker userMarker;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          strokeColor: Colors.amber[100],
          center: latlng,
          fillColor: Colors.amber[100].withOpacity(0.25),
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
            zoom: 18,
            bearing: userLocation.heading,
          ),
        ),
      );

      currentCoordinate = LatLng(userLocation.latitude, userLocation.longitude);

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
        currentCoordinate =
            LatLng(newLocationData.latitude, newLocationData.longitude);
      });
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        debugPrint("Permission Denied: Please try again");
      }
    }
  }

  JoystickDirectionCallback onDirectionChanged(
      double degrees, double distance) {
    // new Y
    var newLat = currentCoordinate.latitude +
        cos(degrees * pi / 180) * distance * 0.00025;
    // new X
    var newLong = currentCoordinate.longitude +
        sin(degrees * pi / 180) * distance * 0.00025;

    currentCoordinate = LatLng(newLat, newLong);

    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(newLat, newLong),
          tilt: Provider.of<TiltLevel>(context, listen: false).tiltLevel,
          zoom: 18,
        ),
      ),
    );
  }

  bool inDistance(LatLng currentPosition, LatLng pressPosition) {
    var lat1 = currentPosition.latitude;
    var lat2 = pressPosition.latitude;
    var lon1 = currentPosition.longitude;
    var lon2 = pressPosition.longitude;
    var R = 6378.137; // Radius of earth in KM
    var dLat = lat2 * pi / 180 - lat1 * pi / 180;
    var dLon = lon2 * pi / 180 - lon1 * pi / 180;
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // meters
    return d * 1000 < postRadius;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final enableButton = Provider.of<Settings>(context).enableMapButton;
    var initialUserLocation =
        Provider.of<UserLocation>(context, listen: false).userLocation;
    currentCoordinate = initialUserLocation == null
        ? currentCoordinate
        : LatLng(initialUserLocation.latitude, initialUserLocation.longitude);
    userMarker = Provider.of<UserLocation>(context, listen: false).userMarker;

    var postArea = Provider.of<UserLocation>(context, listen: false).postArea;
    var markersProvider = Provider.of<MarkersNotifier>(context, listen: false);
    var markersRealTime = Provider.of<MarkersNotifier>(context);

    return Stack(
      children: <Widget>[
        GoogleMap(
          onLongPress: (LatLng pressCoordinate) async {
            if (widget.allowPost &&
                inDistance(currentCoordinate, pressCoordinate)) {
              var marker = Marker(
                  icon: BitmapDescriptor.defaultMarker,
                  markerId: MarkerId('long-pressed-coordinate'),
                  draggable: false,
                  position: pressCoordinate);

              var screenShotData;
              await Future<void>(() {
                setState(() {
                  markersProvider.add(marker);
                });
              }).whenComplete(() async {
                _googleMapController
                    .moveCamera(CameraUpdate.newLatLng(pressCoordinate));
                await Future.delayed(Duration(milliseconds: 50))
                    .then((_) async {
                  screenShotData = await _googleMapController.takeSnapshot();
                });
              }).whenComplete(() {
                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (context) {
                      return PostPopupCard(
                        latlng: pressCoordinate,
                        screenshotData: screenShotData,
                      );
                    },
                  ),
                ).then((_) {
                  setState(() {
                    markersProvider.remove(
                        Marker(markerId: MarkerId('long-pressed-coordinate')));
                  });
                });
              });
            } else {
              // DO NOTHING
            }
          },
          mapType: MapType.normal,
          compassEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: widget.forceNavigation
              ? CameraPosition(target: widget.initialCoordinate, zoom: 18)
              : CameraPosition(
                  target: initialUserLocation == null
                      ? currentCoordinate
                      : LatLng(initialUserLocation.latitude,
                          initialUserLocation.longitude),
                  tilt:
                      Provider.of<TiltLevel>(context, listen: false).tiltLevel,
                  zoom: 18,
                  bearing: initialUserLocation == null
                      ? 0
                      : initialUserLocation.heading,
                ),
          markers: userMarker == null
              ? Set.from(markersRealTime.markers)
              : Set.from(markersRealTime.markers..add(userMarker)),
          circles: {
            if (postArea != null) postArea,
          },
          onMapCreated: (GoogleMapController controller) {
            _googleMapController = controller;
            Provider.of<MapController>(context, listen: false)
                .updateController(controller);
          },
        ),
        if (enableButton)
          Align(alignment: Alignment.bottomLeft, child: TiltButton()),
        if (enableButton)
          Positioned(
            top: mediaQuery.size.height * 4 / 5,
            left: mediaQuery.size.width / 3,
            child: ManeuverButton(
              size: mediaQuery.size.width / 3,
              onDirectionChange: onDirectionChanged,
            ),
          ),
        Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  child: FloatingActionButton(
                    heroTag: 'refreshBtn',
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    onPressed: () {
                      Provider.of<MarkersNotifier>(context, listen: false)
                          .runFetchPostMarkers(context);
                    },
                    child: const Icon(Icons.refresh),
                  ),
                ),
                CurrentUserLocationButton(getCurrentLocation),
              ],
            )),
      ],
    );
  }
}
