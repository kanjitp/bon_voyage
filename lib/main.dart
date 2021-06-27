import 'dart:io';

import 'package:bon_voyage_a_new_experience/providers/chats.dart';
import 'package:bon_voyage_a_new_experience/providers/users.dart';
import 'package:bon_voyage_a_new_experience/screens/add_chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/chat_screen.dart';
import './screens/main_screen.dart';
import './screens/pin_screen.dart';
import './screens/profile_screen.dart';
import './screens/splash_screen.dart';
import './screens/error_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/auth_screen.dart';
import './providers/mapController.dart';
import './providers/tilt_level.dart';
import './providers/user_location.dart';
import 'providers/current_user.dart';

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
class BonVoyage extends StatelessWidget {
  AsyncSnapshot appSnapShot;

  BonVoyage(this.appSnapShot);

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
      ],
      child: MaterialApp(
        title: 'Bon Voyage',
        debugShowCheckedModeBanner: false,
        home: appSnapShot.connectionState != ConnectionState.done
            ? SplashScreen()
            : StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (ctx, userSnapshot) {
                  if (userSnapshot.hasData) {
                    // load all the chats initially
                    return MainScreen();
                  } else {
                    return AuthScreen();
                  }
                }),
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
          AddChatScreen.routeName: (ctx) => AddChatScreen(),
        },
      ),
    );
  }
}
