import 'package:flutter/material.dart';

class HeadBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          BackButton(color: Colors.black, onPressed: () {}),
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
