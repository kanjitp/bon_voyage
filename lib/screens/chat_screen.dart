import 'package:bon_voyage/screens/main_screen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  static final routeName = '/chat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
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
