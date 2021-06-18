import 'package:bon_voyage/widgets/BonVoyageMap.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/profilepage/headbar.dart';
import '../widgets/profilepage/profilepic.dart';
import '../widgets/profilepage/username.dart';
import '../widgets/profilepage/userstat.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  final User user = User(
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
  _ProfilePageState createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

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
                                        onPressed: () {},
                                      ))
                                ],
                              )),
                          Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Username(
                                    firstname: widget.user.firstName,
                                    lastname: widget.user.lastName,
                                    username: widget.user.userName,
                                  ),
                                  UserStat(
                                    memNum: widget.user.memories.length,
                                    followerNum: widget.user.followers.length,
                                    followingNum: widget.user.followings.length,
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
                                    widget.user.firstName + '\'s Map',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
        )),
      ),
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF7CA56)),
    );
  }
}
