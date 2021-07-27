import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/post.dart';

class PostStat extends StatefulWidget {
  final Post memory;
  final Function like;
  final Function startAddComment;

  PostStat(this.memory, this.like, this.startAddComment);

  @override
  _PostStatState createState() => _PostStatState();
}

class _PostStatState extends State<PostStat> {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context, listen: false).user;

    return Container(
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.memory.postId)
                  .snapshots(),
              builder: (ctx, postSnapshot) {
                if (!postSnapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  return Column(
                      //Like
                      children: <Widget>[
                        postSnapshot.data['likers'].contains(currentUser.userId)
                            ? IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.red[800],
                                ),
                                onPressed: () => widget.like())
                            : IconButton(
                                icon: Icon(Icons.favorite_outline),
                                onPressed: () => widget.like()),
                        Text(postSnapshot.data['likers'].length.toString())
                      ]);
                }
              }),
          Column(
            //Comment
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.comment_outlined),
                  onPressed: () => widget.startAddComment(context)),
              Text(widget.memory.comments.length.toString()),
            ],
          ),
          Column(
            //Share
            children: <Widget>[
              IconButton(icon: Icon(Icons.send_outlined), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
