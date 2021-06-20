import 'dart:io';

import 'package:bon_voyage/providers/mapController.dart';
import 'package:bon_voyage/providers/tilt_level.dart';
import 'package:bon_voyage/providers/user_location.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/chat_screen.dart';
import './screens/main_screen.dart';
import './screens/pin_screen.dart';
import './screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (pCtx) => UserLocation()),
        ChangeNotifierProvider(create: (pCtx) => TiltLevel()),
        ChangeNotifierProvider(create: (pCtx) => MapController())
      ],
      child: MaterialApp(
        title: 'Bon Voyage',
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
        theme: ThemeData(
          primaryColor: Color.fromARGB(0xFF, 0xF7, 0xCA, 0x56),
          accentColor: Color.fromARGB(0xFF, 0x00, 0x3C, 0x76),
          cursorColor: Colors.black,
          textTheme: ThemeData.light().textTheme.copyWith(
                headline1: TextStyle(),
              ),
        ),
        routes: {
          MainScreen.routeName: (ctx) => MainScreen(),
          ProfileScreen.routeName: (ctx) => ProfileScreen(),
          ChatScreen.routeName: (ctx) => ChatScreen(),
          PinScreen.routeName: (ctx) => PinScreen()
        },
      ),
    );
  }
}
