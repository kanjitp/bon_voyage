import 'package:bon_voyage/providers/user.dart';
import 'package:bon_voyage/screens/setting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './chat_screen.dart';
import './pin_screen.dart';
import './profile_screen.dart';
import '../widgets/bonVoyageMap.dart';

class MainScreen extends StatefulWidget {
  static final routeName = '/main';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isInit = true;

  @override
  void initState() {
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
      return;
    });
    fbm.subscribeToTopic('chat');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<CurrentUser>(context, listen: false).update();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final double iconSize = mediaQuery.size.width * 0.075;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          BonVoyageMap(),
          Positioned(
            left: mediaQuery.size.width * 0.8825,
            top: mediaQuery.size.height * 0.130,
            child: Column(
              children: <Widget>[
                ChatIcon(iconSize),
                SizedBox(height: mediaQuery.size.height * 0.025),
                ProfileIcon(iconSize),
                SizedBox(height: mediaQuery.size.height * 0.025),
                PinIcon(iconSize),
                SizedBox(height: mediaQuery.size.height * 0.025),
                SettingIcon(iconSize),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileIcon extends StatelessWidget {
  final double size;

  const ProfileIcon(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        border: Border.all(width: 1.5),
        borderRadius: BorderRadius.circular(3000),
      ),
      child: InkWell(
        splashColor: Theme.of(context).primaryColor,
        onTap: () {
          Navigator.pushReplacement(
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
                return ProfileScreen();
              },
              transitionDuration: Duration(milliseconds: 200),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Icon(
          Icons.account_circle_rounded,
          color: Theme.of(context).accentColor,
          size: size,
        ),
      ),
    );
  }
}

class ChatIcon extends StatelessWidget {
  final double size;

  const ChatIcon(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        border: Border.all(width: 1.5),
        borderRadius: BorderRadius.circular(3000),
      ),
      child: InkWell(
        splashColor: Theme.of(context).accentColor,
        onTap: () {
          Navigator.pushReplacement(
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
                return ChatScreen();
              },
              transitionDuration: Duration(milliseconds: 200),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Icon(
          Icons.bubble_chart,
          color: Theme.of(context).accentColor,
          size: size,
        ),
      ),
    );
  }
}

class PinIcon extends StatelessWidget {
  final double size;

  const PinIcon(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        border: Border.all(width: 1.5),
        borderRadius: BorderRadius.circular(3000),
      ),
      child: InkWell(
        splashColor: Theme.of(context).accentColor,
        onTap: () {
          Navigator.pushReplacement(
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
                return PinScreen();
              },
              transitionDuration: Duration(milliseconds: 200),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Icon(
          Icons.push_pin,
          color: Theme.of(context).accentColor,
          size: size,
        ),
      ),
    );
  }
}

class SettingIcon extends StatelessWidget {
  final double size;

  const SettingIcon(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        border: Border.all(width: 1.5),
        borderRadius: BorderRadius.circular(3000),
      ),
      child: InkWell(
        splashColor: Theme.of(context).accentColor,
        onTap: () {
          Navigator.pushReplacement(
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
                return SettingScreen();
              },
              transitionDuration: Duration(milliseconds: 200),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Icon(
          Icons.settings,
          color: Theme.of(context).accentColor,
          size: size,
        ),
      ),
    );
  }
}
