import 'package:bon_voyage_a_new_experience/widgets/myBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../widgets/profilepage/headbar.dart';
import '../widgets/profilepage/profilepic.dart';
import '../widgets/profilepage/username.dart';
import '../widgets/profilepage/userstat.dart';
import '../providers/current_user.dart';
import './edit_profile_screen.dart';
import '../widgets/BonVoyageMap.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfilePageState createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final userProvider = Provider.of<CurrentUser>(context, listen: false);

    final appBar = PreferredSize(
      preferredSize: Size.fromHeight(mediaQuery.size.height * 0.075),
      child: HeadBar(context),
    );

    final upperHeight = (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top) *
        0.28;
    final mapHeight = (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top) *
        0.66;

    return MaterialApp(
      home: Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                  height: upperHeight,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                                width: mediaQuery.size.width * 0.30,
                                margin: EdgeInsets.only(
                                    left: mediaQuery.size.width * 0.05),
                                child: Column(
                                  children: <Widget>[
                                    ProfilePic(),
                                    SizedBox(
                                      height: mediaQuery.size.height * 0.01,
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: mediaQuery.size.height * 0.01),
                                        height: mediaQuery.size.height * 0.02,
                                        child: RaisedButton(
                                          color: Color(0xEFF7CA56),
                                          elevation: 8,
                                          child: Text(
                                            'Edit Profile',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              PageRouteBuilder(
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  var begin = Offset(0.0, 1.0);
                                                  var end = Offset.zero;
                                                  var curve = Curves.ease;

                                                  var tween = Tween(
                                                          begin: begin,
                                                          end: end)
                                                      .chain(CurveTween(
                                                          curve: curve));

                                                  return SlideTransition(
                                                    position:
                                                        animation.drive(tween),
                                                    child: child,
                                                  );
                                                },
                                                pageBuilder: (context,
                                                    animation, animationTime) {
                                                  return EditProfileScreen();
                                                },
                                                transitionDuration:
                                                    Duration(milliseconds: 200),
                                              ),
                                            );
                                          },
                                        ))
                                  ],
                                )),
                            Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Username(
                                      name: userProvider.user.name == null
                                          ? 'pending'
                                          : userProvider.user.name,
                                      username: userProvider.user.username,
                                    ),
                                    UserStat(
                                      memNum: 0,
                                      followerNum: 0,
                                      followingNum: 0,
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.only(
                                    left: mediaQuery.size.width * 0.08)),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                left: mediaQuery.size.width * 0.05,
                                top: mediaQuery.size.height * 0.016),
                            child: Row(
                              children: <Widget>[
                                Container(
                                    width: mediaQuery.size.width * 0.30,
                                    margin: EdgeInsets.only(
                                        top: mediaQuery.size.height * 0.03),
                                    child: Text(
                                      userProvider.user.name == null
                                          ? 'pending'
                                          : userProvider.user.name + '\'s Map',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(width: mediaQuery.size.width * 0.2),
                                // Dummy icon button for now
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                          icon: Icon(Icons.account_tree),
                                          onPressed: () {}),
                                      SizedBox(
                                        width: mediaQuery.size.width * 0.02,
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.account_tree),
                                          onPressed: () {}),
                                      SizedBox(
                                        width: mediaQuery.size.width * 0.02,
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.account_tree),
                                          onPressed: () {})
                                    ])
                              ],
                            ))
                      ])),
              Container(height: mapHeight, child: BonVoyageMap()),
            ],
          ),
        ),
      ),
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF7CA56)),
    );
  }
}
