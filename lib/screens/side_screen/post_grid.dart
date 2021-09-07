import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../post_screen/post_grid_item.dart';

import '../../../models/post.dart';
import '../../../models/user.dart';

class PostGrid extends StatelessWidget {
  final String field;
  PostGrid({Key key, @required this.user, @required this.field})
      : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
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
