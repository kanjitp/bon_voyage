import 'package:flutter/material.dart';
import './main_screen.dart';

class PinScreen extends StatelessWidget {
  static final routeName = '/pin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pin Screen'),
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(-1.0, 0.0), end: Offset.zero)
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
          },
        ),
        actions: <Widget>[],
      ),
    );
  }
}
