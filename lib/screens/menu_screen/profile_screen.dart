import 'package:bon_voyage_a_new_experience/models/post.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post_grid_item.dart';
import 'package:bon_voyage_a_new_experience/widgets/myBottomNavigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../widgets/profilepage/headbar.dart';
import '../../widgets/profilepage/profilepic.dart';
import '../../widgets/profilepage/username.dart';
import '../../widgets/profilepage/userstat.dart';
import '../../providers/current_user.dart';
import 'profile/edit_profile_screen.dart';
import '../../widgets/BonVoyageMap.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfilePageState createState() {
    return _ProfilePageState();
  }
}

enum ProfileMode { map, memories, tagged }

class _ProfilePageState extends State<ProfileScreen> {
  ProfileMode currentMode = ProfileMode.map;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final userProvider = Provider.of<CurrentUser>(context, listen: false);

    return SafeArea(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        ProfilePic(),
                        SizedBox(
                          height: mediaQuery.size.height * 0.01,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Username(
                          name: userProvider.user.name == null
                              ? 'pending'
                              : userProvider.user.name,
                          username: userProvider.user.username,
                        ),
                        UserStat(
                          memNum: userProvider.user.memories.length,
                          followerNum: userProvider.user.followers.length,
                          followingNum: userProvider.user.followings.length,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(children: [
                  Expanded(
                    child: Container(
                        height: mediaQuery.size.height * 0.03,
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
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
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var begin = Offset(0.0, 1.0);
                                  var end = Offset.zero;
                                  var curve = Curves.ease;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                                pageBuilder:
                                    (context, animation, animationTime) {
                                  return EditProfileScreen();
                                },
                                transitionDuration: Duration(milliseconds: 200),
                              ),
                            );
                          },
                        )),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    if (currentMode == ProfileMode.map)
                      Text(
                        userProvider.user.name == null
                            ? 'pending'
                            : userProvider.user.username + '\'s Map',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    if (currentMode == ProfileMode.memories)
                      Text(
                        userProvider.user.name == null
                            ? 'pending'
                            : userProvider.user.username + '\'s memories',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    if (currentMode == ProfileMode.tagged)
                      Text(
                        userProvider.user.name == null
                            ? 'pending'
                            : userProvider.user.username + '\'s tags',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    // Dummy icon button for now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                            icon: currentMode == ProfileMode.map
                                ? Icon(
                                    Icons.location_on_rounded,
                                    color: Theme.of(context).splashColor,
                                  )
                                : Icon(Icons.location_on_rounded),
                            onPressed: () {
                              setState(() {
                                currentMode = ProfileMode.map;
                              });
                            }),
                        SizedBox(
                          width: mediaQuery.size.width * 0.02,
                        ),
                        IconButton(
                            icon: currentMode == ProfileMode.memories
                                ? Icon(
                                    Icons.grid_on_rounded,
                                    color: Theme.of(context).splashColor,
                                  )
                                : Icon(Icons.grid_on_rounded),
                            onPressed: () {
                              setState(() {
                                currentMode = ProfileMode.memories;
                              });
                            }),
                        SizedBox(
                          width: mediaQuery.size.width * 0.02,
                        ),
                        IconButton(
                            icon: currentMode == ProfileMode.tagged
                                ? Icon(
                                    Icons.supervised_user_circle_outlined,
                                    color: Theme.of(context).splashColor,
                                  )
                                : Icon(Icons.supervised_user_circle_outlined),
                            onPressed: () {
                              setState(() {
                                currentMode = ProfileMode.tagged;
                              });
                            })
                      ],
                    )
                  ],
                ),
              ],
            ),
            if (currentMode == ProfileMode.map)
              Expanded(
                child: BonVoyageMap(
                  allowPost: false,
                ),
              ),
            if (currentMode == ProfileMode.memories)
              Expanded(
                child: PostGrid(
                  userProvider: userProvider,
                  field: 'posts',
                ),
              ),
            if (currentMode == ProfileMode.tagged)
              Expanded(
                  child: PostGrid(
                userProvider: userProvider,
                field: 'tagged_posts',
              )),
          ],
        ),
      ),
    );
  }
}

class PostGrid extends StatelessWidget {
  final String field;
  PostGrid({Key key, @required this.userProvider, @required this.field})
      : super(key: key);

  final CurrentUser userProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userProvider.user.userId)
            .snapshots(),
        builder: (ctx, currentUserSnapshot) {
          if (!currentUserSnapshot.hasData) {
            return Container();
          } else {
            final postIds = currentUserSnapshot.data[field];
            return GridView.builder(
              itemCount: postIds.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0),
              itemBuilder: (ctx, index) {
                final postDoc = postIds[index];
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postDoc)
                      .snapshots(),
                  builder: (ctx, postSnapshot) {
                    if (!postSnapshot.hasData) {
                      return CircularProgressIndicator();
                    } else {
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(postSnapshot.data['creator'])
                            .snapshots(),
                        builder: (ctx, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return Container();
                          } else {
                            return PostGridItem(
                              memory: Post(
                                postId: postDoc,
                                creator: User(
                                  userId: postSnapshot.data['creator'],
                                  username: userSnapshot.data['username'],
                                  imageURL: userSnapshot.data['imageUrl'],
                                  name: userSnapshot.data['name'],
                                ),
                                imageURL: postSnapshot.data['imageUrl'],
                                caption: postSnapshot.data['caption'],
                                likers: postSnapshot.data['likers'],
                                latlng: LatLng(postSnapshot.data['lat'],
                                    postSnapshot.data['lng']),
                                comments: postSnapshot.data['comments'],
                                taggedUsers: postSnapshot.data['tagged_users'],
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
