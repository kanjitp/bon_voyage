import 'package:flutter/material.dart';

class CurrentUserLocationButton extends StatelessWidget {
  final Function getCurrentLocation;
  const CurrentUserLocationButton(this.getCurrentLocation, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: FloatingActionButton(
        heroTag: 'locBtn',
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () {
          getCurrentLocation();
        },
        child: const Icon(
          Icons.location_searching_rounded,
        ),
      ),
    );
  }
}
