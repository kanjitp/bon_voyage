import 'dart:math';

import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/taggedUsers.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/create_post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class SearchTag extends StatefulWidget {
  Function update;

  SearchTag({this.update});

  @override
  _SearchTagState createState() => _SearchTagState();
}

class _SearchTagState extends State<SearchTag> {
  var _query = "";

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final taggedUsers = Provider.of<TaggedUsers>(context).of(id: 'create-post');
    return FloatingSearchBar(
      backdropColor: Colors.transparent,
      autocorrect: false,
      borderRadius: BorderRadius.circular(8),
      hint: "Search Travelers...",
      onQueryChanged: (newQuery) {
        setState(() {
          _query = newQuery == null ? "" : newQuery;
        });
      },
      body: Center(
          child: Text(
        'Use search bar above to tag fellow travellers',
        style: TextStyle(color: Colors.black38),
      )),
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
                      (user.name.toLowerCase().contains(_query.toLowerCase()) ||
                          user.username
                              .toLowerCase()
                              .contains(_query.toLowerCase())) &&
                      !taggedUsers.contains(user))
                  .toList();
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.white,
                  child: new ListView.builder(
                    shrinkWrap: true,
                    itemCount: min(users.length, 4),
                    itemBuilder: (context, index) {
                      User user = users[index];
                      return QueryCard(
                        user: user,
                        update: () => (widget.update()),
                        ctx: context,
                      );
                    },
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class QueryCard extends StatelessWidget {
  final User user;
  Function update;
  BuildContext ctx;
  QueryCard({@required this.user, @required this.update, @required this.ctx});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Provider.of<TaggedUsers>(ctx, listen: false)
            .addTo(user: user, id: CreatePostScreen.id);
        update();
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
