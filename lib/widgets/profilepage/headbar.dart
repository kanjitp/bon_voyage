import 'package:bon_voyage/screens/main_screen.dart';
import 'package:flutter/material.dart';

class HeadBar extends StatelessWidget {
  final BuildContext currentContext;

  HeadBar(this.currentContext);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          BackButton(
              color: Colors.black,
              onPressed: () {
                Navigator.of(currentContext)
                    .pushReplacementNamed(MainScreen.routeName);
              }),
          Text(
            'Profile',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF7CA56),
      elevation: 0,
    );
  }
}
