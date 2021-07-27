import 'package:bon_voyage_a_new_experience/logics/custom_rect_tween.dart';
import 'package:bon_voyage_a_new_experience/models/user_presence.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_screen.dart';
import '../main_screen.dart';

class LogoutPopupCard extends StatelessWidget {
  static const String _logoutPopup = 'log-out';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _logoutPopup,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Material(
            color: Colors.white,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Text(
                    'Are you sure you want to log out?',
                    textAlign: TextAlign.center,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        FlatButton(
                          onPressed: () async {
                            await UserPresence.forceUpdateOffline()
                                .then((_) => FirebaseAuth.instance.signOut());
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
                                pageBuilder:
                                    (context, animation, animationTime) {
                                  return StreamBuilder(
                                      stream: FirebaseAuth.instance
                                          .authStateChanges(),
                                      builder: (ctx, userSnapshot) {
                                        if (userSnapshot.hasData &&
                                            userSnapshot.data.emailVerified) {
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
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
