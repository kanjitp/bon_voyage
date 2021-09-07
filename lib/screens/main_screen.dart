import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../screens/menu_screen.dart';

import './setting_screen.dart';
import '../widgets/bonVoyageMap.dart';
import '../providers/current_user.dart';

class MainScreen extends StatefulWidget {
  static final routeName = '/main';

  final initialCameraPosition;
  final forceNavigation;

  MainScreen([this.initialCameraPosition, this.forceNavigation = false]);

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
          BonVoyageMap(
            initialCoordinate: widget.initialCameraPosition,
            forceNavigation: widget.forceNavigation,
          ),
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
          Positioned(
            right: mediaQuery.size.width * 0.8825,
            top: mediaQuery.size.height * 0.130,
            child: Column(
              children: <Widget>[FeedIcon(iconSize)],
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
    return MenuButton(
        menuType: Menu.profile, size: size, icon: Icons.account_circle_rounded);
  }
}

class ChatIcon extends StatelessWidget {
  final double size;

  const ChatIcon(this.size);

  @override
  Widget build(BuildContext context) {
    return MenuButton(
      size: size,
      menuType: Menu.chats,
      icon: Icons.bubble_chart,
    );
  }
}

class PinIcon extends StatelessWidget {
  final double size;

  const PinIcon(this.size);

  @override
  Widget build(BuildContext context) {
    return MenuButton(menuType: Menu.myPin, size: size, icon: Icons.push_pin);
  }
}

class FeedIcon extends StatelessWidget {
  final double size;

  const FeedIcon(this.size);

  @override
  Widget build(BuildContext context) {
    return MenuButton(menuType: Menu.myFeed, size: size, icon: Icons.home);
  }
}

class MenuButton extends StatelessWidget {
  Menu menuType;
  IconData icon;

  MenuButton(
      {Key key,
      @required this.menuType,
      @required this.size,
      @required this.icon})
      : super(key: key);

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
        splashColor: Theme.of(context).accentColor,
        onTap: () async {
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
                return MenuScreen(
                  menuType: menuType,
                  currentUser: Provider.of<CurrentUser>(context).user,
                );
              },
              transitionDuration: Duration(milliseconds: 200),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Icon(
          icon,
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
