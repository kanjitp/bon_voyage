import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './providers/chats.dart';
import './providers/file_provider.dart';
import './providers/markers_notifier.dart';
import './providers/posts.dart';
import './providers/settings.dart';
import './providers/taggedUsers.dart';
import './providers/users.dart';
import './providers/mapController.dart';
import './providers/tilt_level.dart';
import './providers/user_location.dart';
import './providers/current_user.dart';

import './screens/setting_screen.dart';

import './screens/main_screen.dart';
import './screens/menu_screen/pin_screen.dart';
import './screens/menu_screen/profile_screen.dart';
import './screens/splash_screen.dart';
import './screens/menu_screen/profile/edit_profile_screen.dart';
import './screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return FutureBuilder(
      future: _initialization,
      builder: (context, appSnapshot) {
        return BonVoyage(appSnapshot);
      },
    );
  }
}

// ignore: must_be_immutable
class BonVoyage extends StatefulWidget {
  AsyncSnapshot appSnapShot;

  BonVoyage(this.appSnapShot);

  @override
  _BonVoyageState createState() => _BonVoyageState();
}

class _BonVoyageState extends State<BonVoyage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (pCtx) => UserLocation()),
        ChangeNotifierProvider(create: (pCtx) => TiltLevel()),
        ChangeNotifierProvider(create: (pCtx) => MapController()),
        ChangeNotifierProvider(create: (pCtx) => CurrentUser()),
        ChangeNotifierProvider(create: (pCtx) => Users()),
        ChangeNotifierProvider(create: (pCtx) => Chats()),
        ChangeNotifierProvider(create: (pCtx) => Settings()),
        ChangeNotifierProvider(create: (pCtx) => MarkersNotifier()),
        ChangeNotifierProvider(create: (pCtx) => TaggedUsers()),
        ChangeNotifierProvider(create: (pCtx) => FileProvider()),
        ChangeNotifierProvider(create: (pCtx) => Posts())
      ],
      child: MaterialApp(
        title: 'Bon Voyage',
        debugShowCheckedModeBanner: false,
        home: widget.appSnapShot.connectionState != ConnectionState.done
            ? SplashScreen()
            : StreamBuilder(
                stream: FirebaseAuth.instance
                    .authStateChanges()
                    .where((user) => user.emailVerified),
                builder: (ctx, userSnapshot) {
                  if (userSnapshot.hasData &&
                      userSnapshot.requireData.emailVerified) {
                    return MainScreen();
                  } else {
                    return AuthScreen();
                  }
                },
              ),
        theme: ThemeData(
            primaryColor: Color.fromARGB(0xFF, 0xF7, 0xCA, 0x56),
            accentColor: Color.fromARGB(0xFF, 0x00, 0x3C, 0x76),
            focusColor: Color.fromARGB(0xFF, 0x81, 0x87, 0xC6),
            splashColor: Color.fromARGB(0xFF, 0x48, 0x57, 0x77),
            errorColor: Color.fromARGB(0xFF, 0xEF, 0x0B, 0x40),
            primarySwatch: Colors.blueGrey,
            accentColorBrightness: Brightness.dark,
            cursorColor: Colors.black,
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline1: TextStyle(),
                ),
            buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: Color.fromARGB(0xFF, 0x41, 0x5a, 0x8e),
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Color.fromARGB(0xFF, 0xF7, 0xCA, 0x56),
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Color.fromARGB(0xFF, 0x48, 0x57, 0x77),
              selectedIconTheme:
                  IconThemeData(color: Color.fromARGB(0xFF, 0x00, 0x3C, 0x76)),
            )),
        routes: {
          MainScreen.routeName: (ctx) => MainScreen(),
          ProfileScreen.routeName: (ctx) => ProfileScreen(),
          PinScreen.routeName: (ctx) => PinScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
          SettingScreen.routeName: (ctx) => SettingScreen(),
        },
      ),
    );
  }
}
