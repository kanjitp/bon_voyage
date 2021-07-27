import 'dart:math';

import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/screens/side_screen/traveler_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class TravelersScreen extends StatefulWidget {
  TravelersScreen({Key key}) : super(key: key);

  @override
  _TravelersScreenState createState() => _TravelersScreenState();
}

enum ProfileMode { map, memories, tagged }

class _TravelersScreenState extends State<TravelersScreen> {
  String _query = " ";
  User currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<CurrentUser>(context).user;
    final mediaQuery = MediaQuery.of(context);
    return buildFloatingSearchBar(currentUser);
  }

  Widget buildFloatingSearchBar(User currentUser) {
    return Container(
      color: Colors.white70,
      child: FloatingSearchBar(
        autocorrect: false,
        borderRadius: BorderRadius.circular(8),
        hint: "Search Travelers...",
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                List<dynamic> followerIds = snapshot.data['followers'];
                List<dynamic> followingIds = snapshot.data['followings'];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Text('Followers: ${followerIds.length.toString()}'),
                          SizedBox(
                            height: 25,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: followerIds.length,
                            itemBuilder: (ctx, index) {
                              String followerId = followerIds[index];
                              return FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(followerId)
                                    .get(),
                                builder: (ctx, userSnapshot) {
                                  if (!userSnapshot.hasData) {
                                    return CircularProgressIndicator();
                                  } else {
                                    return TravelerCard(
                                      user: User(
                                        userId: followerId,
                                        name: userSnapshot.data['name'],
                                        username: userSnapshot.data['username'],
                                        imageURL: userSnapshot.data['imageUrl'],
                                        chats: userSnapshot.data['chats'],
                                        followers:
                                            userSnapshot.data['followers'],
                                        followings:
                                            userSnapshot.data['followings'],
                                        memories: userSnapshot.data['posts'],
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Text('Following: ${followingIds.length.toString()}'),
                          SizedBox(
                            height: 25,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: followingIds.length,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemBuilder: (ctx, index) {
                              var followingId = followingIds[index];
                              return FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(followingId)
                                    .get(),
                                builder: (ctx, userSnapshot) {
                                  if (!userSnapshot.hasData) {
                                    return CircularProgressIndicator();
                                  } else {
                                    return TravelerCard(
                                      user: User(
                                        userId: followingId,
                                        name: userSnapshot.data['name'],
                                        username: userSnapshot.data['username'],
                                        imageURL: userSnapshot.data['imageUrl'],
                                        chats: userSnapshot.data['chats'],
                                        followers:
                                            userSnapshot.data['followers'],
                                        followings:
                                            userSnapshot.data['followings'],
                                        memories: userSnapshot.data['posts'],
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            }),
        onQueryChanged: (newQuery) {
          setState(() {
            _query = newQuery == null ? "" : newQuery;
          });
        },
        builder: (context, transition) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                List<dynamic> users = snapshot.data.docs
                    .map((DocumentSnapshot doc) => User(
                          userId: doc.id,
                          username: doc['username'],
                          name: doc['name'],
                          imageURL: doc['imageUrl'],
                          followers: doc['followers'],
                          followings: doc['followings'],
                          memories: doc['posts'],
                          chats: doc['chats'],
                        ))
                    .toList();
                users = users
                    .where((user) =>
                        user.name
                            .toLowerCase()
                            .contains(_query.toLowerCase()) ||
                        user.username
                            .toLowerCase()
                            .contains(_query.toLowerCase()))
                    .toList();
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.white,
                    child: new ListView.builder(
                      shrinkWrap: true,
                      itemCount: min(users.length, 8),
                      itemBuilder: (context, index) {
                        User user = users[index];
                        return QueryCard(
                          user: user,
                        );
                      },
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class QueryCard extends StatelessWidget {
  final User user;

  QueryCard({@required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
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
              return TravelerProfileScreen(
                user: user,
                currentUser: Provider.of<CurrentUser>(context).user,
              );
            },
            transitionDuration: Duration(milliseconds: 200),
          ),
        );
      },
      child: Container(
        color: Colors.transparent,
        height: 50,
        margin: EdgeInsets.all(3),
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: user.imageURL == null
                  ? AssetImage('./assets/images/dummy_user.png')
                  : NetworkImage(user.imageURL),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(),
                ),
                Text(
                  '@' + user.username,
                  style: TextStyle(color: Colors.black38),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TravelerCard extends StatelessWidget {
  final User user;

  TravelerCard({@required this.user});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: InkWell(
        onTap: () async {
          print(user.userId);
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
                return TravelerProfileScreen(
                  user: user,
                  currentUser: Provider.of<CurrentUser>(context).user,
                );
              },
              transitionDuration: Duration(milliseconds: 200),
            ),
          );
        },
        child: Card(
          elevation: 10,
          margin: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user.imageURL == null
                      ? AssetImage('./assets/images/dummy_user.png')
                      : NetworkImage(user.imageURL),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(),
                    ),
                    Text(
                      '@' + user.username,
                      style: TextStyle(color: Colors.black38),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
