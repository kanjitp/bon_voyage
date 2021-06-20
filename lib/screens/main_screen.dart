import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final double iconSize = mediaQuery.size.width * 0.075;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          BonVoyageMap(),
          Positioned(
            left: mediaQuery.size.width * 0.875,
            top: mediaQuery.size.height * 0.1,
            child: Column(
              children: <Widget>[
                ChatIcon(iconSize),
                SizedBox(height: mediaQuery.size.height * 0.025),
                ProfileIcon(iconSize),
                SizedBox(height: mediaQuery.size.height * 0.025),
                PinIcon(iconSize),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileIcon extends StatelessWidget {
  const ProfileIcon(
    this.size, {
    Key key,
  }) : super(key: key);

  final double size;

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

  ChatIcon(this.size);

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

  PinIcon(this.size);

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
