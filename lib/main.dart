import 'dart:io';

import './logics/user.dart';
import 'package:flutter/services.dart';
import 'package:bon_voyage/profilepage.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // dummy test
  final User testSubject = User(
      'benwalk',
      'Benjamin',
      'Walker',
      'The important thing is not the destination but the journey',
      [],
      [],
      [],
      DateTime.now(),
      true,
      double.infinity,
      null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bon Voyage',
      home: ProfilePage(testSubject),
      theme: ThemeData(
          primaryColor: Color.fromARGB(0xFF, 0xF7, 0xCA, 0x56),
          cursorColor: Colors.black,
          textTheme:
              ThemeData.light().textTheme.copyWith(headline1: TextStyle())),
    );
  }
}
