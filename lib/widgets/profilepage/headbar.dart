import 'package:flutter/material.dart';

import '../../screens/main_screen.dart';

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
                Navigator.pushReplacement(
                  currentContext,
                  PageRouteBuilder(
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(-1.0, 0.0),
                                end: Offset.zero)
                            .animate(animation),
                        child: child,
                      );
                    },
                    pageBuilder: (context, animation, animationTime) {
                      return MainScreen();
                    },
                    transitionDuration: Duration(milliseconds: 200),
                  ),
                );
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
