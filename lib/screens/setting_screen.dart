import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth_screen.dart';
import './main_screen.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'LOG OUT',
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(0.0, 1.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            pageBuilder: (context, animation, animationTime) {
                              return StreamBuilder(
                                  stream:
                                      FirebaseAuth.instance.authStateChanges(),
                                  builder: (ctx, userSnapshot) {
                                    if (userSnapshot.hasData) {
                                      return MainScreen();
                                    } else {
                                      return AuthScreen();
                                    }
                                  });
                            },
                            transitionDuration: Duration(milliseconds: 200),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
