import 'package:bon_voyage_a_new_experience/logics/hero_dialog_route.dart';
import 'package:bon_voyage_a_new_experience/models/user_presence.dart';
import 'package:bon_voyage_a_new_experience/providers/settings.dart';
import 'package:bon_voyage_a_new_experience/screens/setting/logout_popup_card.dart';
import 'package:bon_voyage_a_new_experience/screens/setting/security_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/auth_screen.dart';
import './main_screen.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  static bool needToRerender = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: BackButton(
          onPressed: () {
            if (needToRerender) {
              needToRerender = false;
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
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0), end: Offset.zero)
                            .animate(animation),
                        child: child,
                      );
                    },
                    pageBuilder: (context, animation, animationTime) {
                      return SecurityScreen();
                    },
                    transitionDuration: Duration(milliseconds: 200),
                  ),
                );
              },
              child: Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Icon(Icons.security),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'Security',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Colors.black45,
                        ),
                      )
                    ],
                  )),
            ),
            Divider(
              thickness: 15,
            ),
            EnableButtonSwitch(),
            Divider(
              thickness: 15,
            ),
            Logout(),
            Divider(),
          ],
        ),
      ),
    );
  }
}

class EnableButtonSwitch extends StatefulWidget {
  const EnableButtonSwitch({
    Key key,
  }) : super(key: key);

  @override
  _EnableButtonSwitchState createState() => _EnableButtonSwitchState();
}

class _EnableButtonSwitchState extends State<EnableButtonSwitch> {
  @override
  Widget build(BuildContext context) {
    bool enableMapButton =
        Provider.of<Settings>(context, listen: false).enableMapButton;
    return Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Icon(Icons.sports_handball),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Enable One Hand Mode (Buttons)',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Switch(
                activeColor: Colors.blueGrey,
                value: enableMapButton,
                onChanged: (value) {
                  setState(() {
                    Provider.of<Settings>(context, listen: false)
                        .setEnableMapButton(!enableMapButton);
                    _SettingScreenState.needToRerender =
                        !_SettingScreenState.needToRerender;
                  });
                })
          ],
        ));
  }
}

class Logout extends StatelessWidget {
  const Logout({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          Navigator.of(context).push(
            HeroDialogRoute(
              builder: (context) {
                return LogoutPopupCard();
              },
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'LOG OUT',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.red[600],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
