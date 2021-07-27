import 'package:bon_voyage_a_new_experience/models/post.dart';
import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/comment.dart';

class CommentList extends StatefulWidget {
  final Post post;
  final Function deleteComment;

  CommentList(this.post, this.deleteComment);

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  void _deleteCommentDialog(BuildContext ctx, String commentId) {
    showDialog(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          title: Text('Delete this comment?'),
          actions: <Widget>[
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red[400])),
              onPressed: () {
                widget.deleteComment(commentId);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
                child:
                    Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                }),
          ],
        );
      },
    );
  }

  void like(User currentUser, String commentId) async {
    final commentData = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postId)
        .collection('comments')
        .doc(commentId)
        .get();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postId)
        .collection('comments')
        .doc(commentId)
        .update({
      'likers': !commentData['likers'].contains(currentUser.userId)
          ? (commentData['likers']..add(currentUser.userId))
          : (commentData['likers']
            ..removeWhere((id) => id == currentUser.userId))
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final currentUser = Provider.of<CurrentUser>(context, listen: false).user;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.postId)
            .collection('comments')
            .orderBy('timestamp')
            .snapshots(),
        builder: (ctx, commentsSnapshot) {
          if (commentsSnapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            final commentsData = commentsSnapshot.data.docs;

            return commentsData.length == 0
                ? Container(
                    //No comments yet
                    width: mediaQuery.size.width * 0.8,
                    height: mediaQuery.size.height * 0.2,
                    padding: EdgeInsets.all(mediaQuery.size.height * 0.05),
                    child: Text('Be the first comment to this memory!',
                        style: TextStyle(color: Colors.grey[700])),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: commentsData.length,
                    //Comment list
                    itemBuilder: (ctx, index) {
                      final commentData = commentsData[index];
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(commentData['creator'])
                            .get(),
                        builder: (ctx, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return CircularProgressIndicator();
                          } else {
                            final userData = userSnapshot.data;
                            final comment = Comment(
                              commendId: commentData.id,
                              content: commentData['content'],
                              user: User(
                                userId: userData.id,
                                username: userData['username'],
                                name: userData['name'],
                                imageURL: userData['imageUrl'],
                              ),
                              likers: commentData['likers'],
                              isLikedByUser: commentData['likers']
                                  .contains(currentUser.userId),
                              timestamp: commentData['timestamp'],
                            );
                            return Card(
                              color: Colors.amber[200],
                              margin: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 20,
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: mediaQuery.size.height * 0.06,
                                  height: mediaQuery.size.height * 0.06,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(comment.user.imageURL),
                                        fit: BoxFit.fill),
                                  ),
                                ), //profilepic
                                title: Text(
                                  comment.user.username,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ), //username as title
                                subtitle: Text(
                                  comment.content,
                                  style: TextStyle(color: Colors.black),
                                ),
                                trailing: FittedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      comment.isLikedByUser //like
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.favorite,
                                                color: Colors.red[800],
                                              ),
                                              onPressed: () => like(currentUser,
                                                  comment.commendId))
                                          : IconButton(
                                              icon:
                                                  Icon(Icons.favorite_outline),
                                              onPressed: () => like(currentUser,
                                                  comment.commendId)),
                                      Text(
                                        comment.likers.length.toString(),
                                      ),
                                    ],
                                  ),
                                ),
                                onLongPress: () {
                                  // allow the owner of the post and comment
                                  // to delete the comment
                                  if (currentUser.userId ==
                                          comment.user.userId ||
                                      currentUser.userId ==
                                          widget.post.creator.userId) {
                                    _deleteCommentDialog(
                                        context, comment.commendId);
                                  }
                                },
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
          }
        });
  }
}
