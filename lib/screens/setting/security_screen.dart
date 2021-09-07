import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/current_user.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key key}) : super(key: key);

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context).user;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Divider(),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.userId)
                .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return CircularProgressIndicator();
              }
              return InformationCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('email:'),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      userSnapshot.data['email'],
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Container(),
              );
            },
          ),
          Divider(),
          InkWell(
            onTap: () async {
              final userData = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.userId)
                  .get();
              await FirebaseAuth.instance
                  .sendPasswordResetEmail(email: userData['email']);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'A password reset link has been sent to ${userData['email']}, please click the link provided to complete your password reset'),
                backgroundColor: Colors.green,
              ));
            },
            child: InformationCard(
              child: Text(
                'Request password reset',
                style: TextStyle(color: Theme.of(context).splashColor),
              ),
              trailing: Row(
                children: [
                  Icon(
                    Icons.vpn_key_rounded,
                    color: Theme.of(context).splashColor,
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Theme.of(context).splashColor,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 10,
          ),
        ],
      ),
    );
  }
}

class InformationCard extends StatelessWidget {
  final Widget child;
  final Widget trailing;

  InformationCard({this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          child,
          SizedBox(
            width: 20,
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
