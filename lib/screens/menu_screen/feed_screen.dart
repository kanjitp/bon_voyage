import 'package:bon_voyage_a_new_experience/widgets/fill_outline_button.dart';
import 'package:bon_voyage_a_new_experience/models/post.dart';
import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/providers/posts.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

enum FeedMode { home, hotAroundMe, archive }

class _FeedScreenState extends State<FeedScreen> {
  FeedMode _mode;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context).user;
    _mode = Provider.of<Posts>(context).currentMode;
    return Container(
      color: Colors.white70,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10, right: 5, bottom: 5),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FillOutlineButton(
                        press: () {
                          setState(() {
                            Provider.of<Posts>(context, listen: false)
                                .setMode(FeedMode.home);
                          });
                        },
                        text: "Home",
                        isFilled: _mode == FeedMode.home),
                    SizedBox(
                      width: 8,
                    ),
                    FillOutlineButton(
                      press: () {
                        setState(() {
                          Provider.of<Posts>(context, listen: false)
                              .setMode(FeedMode.hotAroundMe);
                        });
                      },
                      text: "Hot Around Me",
                      isFilled: _mode == FeedMode.hotAroundMe,
                    ),
                  ],
                ),
                FillOutlineButton(
                    press: () {
                      setState(() {
                        Provider.of<Posts>(context, listen: false)
                            .setMode(FeedMode.archive);
                      });
                    },
                    text: "Archive",
                    isFilled: _mode == FeedMode.archive),
              ],
            ),
          ),
          if (_mode == FeedMode.home || _mode == FeedMode.hotAroundMe)
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('posts').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    final postIds = snapshot.data.docs;
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: postIds.length,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemBuilder: (ctx, index) {
                          final postDoc = postIds[index];
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(postDoc.id)
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
                                          return CircularProgressIndicator();
                                        } else {
                                          final currentUser =
                                              Provider.of<CurrentUser>(context,
                                                      listen: false)
                                                  .user;
                                          return PostCard(
                                            memory: Post(
                                              postId: postDoc.id,
                                              creator: User(
                                                userId: postSnapshot
                                                    .data['creator'],
                                                username: userSnapshot
                                                    .data['username'],
                                                imageURL: userSnapshot
                                                    .data['imageUrl'],
                                                name: userSnapshot.data['name'],
                                              ),
                                              imageURL: postDoc['imageUrl'],
                                              caption: postDoc['caption'],
                                              likers: postDoc['likers'],
                                              latlng: LatLng(postDoc['lat'],
                                                  postDoc['lng']),
                                              comments: postDoc['comments'],
                                              taggedUsers:
                                                  postDoc['tagged_users'],
                                            ),
                                            viewer: currentUser,
                                          );
                                        }
                                      });
                                }
                              });
                        });
                  }
                },
              ),
            )

          // if (_mode == FeedMode.archive)
        ],
      ),
    );
  }
}
