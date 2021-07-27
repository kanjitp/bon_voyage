import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationConfirmation extends StatefulWidget {
  LatLng currentLatLng;

  LocationConfirmation({this.currentLatLng});

  @override
  _LocationConfirmationState createState() => _LocationConfirmationState();
}

class _LocationConfirmationState extends State<LocationConfirmation> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text('Location', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.public,
                  size: 15,
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '(${widget.currentLatLng.latitude.toStringAsFixed(4)}, ${widget.currentLatLng.longitude.toStringAsFixed(4)})',
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.black38),
            )
          ],
        ),
      ],
    );
  }
}
