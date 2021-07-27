import 'package:bon_voyage_a_new_experience/models/user_presence.dart';
import 'package:bon_voyage_a_new_experience/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static final routeName = '/auth';

  AuthScreen({key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

enum AuthMode {
  signUp,
  logIn,
  forgotPassword,
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String name,
    String username,
    AuthMode mode,
    BuildContext ctx,
  ) async {
    UserCredential userCredential;
    try {
      setState(() {
        _isLoading = true;
      });
      if (mode == AuthMode.signUp) {
        // in sign up mode
        print('_submitForm - sign up');
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await userCredential.user.updateDisplayName(username);
        await userCredential.user.sendEmailVerification();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user.uid)
            .set(
          {
            'username': username,
            'email': email,
            'name': name,
            'imageUrl': null,
            'chats': [],
            'followers': [],
            'followings': [],
            'posts': [],
            'pinned_posts': [],
            'tagged_posts': [],
          },
        );

        await FirebaseFirestore.instance
            .collection('status')
            .doc(userCredential.user.uid)
            .set({
          'last_changed': Timestamp.now(),
          'state': "online",
        });

        await FirebaseFirestore.instance
            .collection('archive')
            .doc(userCredential.user.uid)
            .set({
          'chats': [],
          'posts': [],
        });

        await _auth.signOut();

        Scaffold.of(ctx).showSnackBar(SnackBar(
          content: Text(
            'An email has been sent to you, click the link provided to complete signing-up',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ));
        setState(() {
          _isLoading = false;
        });
      } else if (mode == AuthMode.logIn) {
        // in log in mode
        print('_submitForm - login');
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        // 2 lines below reload the user
        await _auth.currentUser.reload();
        await _auth.currentUser.getIdToken(true);
        if (!userCredential.user.emailVerified) {
          Scaffold.of(ctx).showSnackBar(SnackBar(
            content: Text(
              'This account has not been verified yet, please verify your account to complete your registration',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).errorColor,
          ));
          setState(() {
            _isLoading = false;
          });
        } else {}
      } else if (mode == AuthMode.forgotPassword) {
        print('reached');
        await _auth.sendPasswordResetEmail(email: email);
        Scaffold.of(ctx).showSnackBar(SnackBar(
          content: Text(
            'A password reset link has been sent to $email, please click the link provided to complete your password reset',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      var message = 'An error occurred, please check your credentials!';
      if (error.message != null) {
        message = error.message;
      }
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: mediaQuery.size.height * 0.2),
            height: mediaQuery.size.height * .2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45.0),
              child: Image(
                image: AssetImage('assets/images/logo.jpg'),
              ),
            ),
          ),
          AuthForm(_submitAuthForm, _isLoading),
        ],
      ),
    );
  }
}
