import 'package:flutter/material.dart';

class PersonalMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      width: double.infinity,
      color: Colors.grey,
      child: Text(
        'Google Map',
        textAlign: TextAlign.center,
      ),
    );
  }
}
