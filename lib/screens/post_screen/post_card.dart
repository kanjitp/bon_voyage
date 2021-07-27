import 'package:bon_voyage_a_new_experience/logics/custom_rect_tween.dart';
import 'package:bon_voyage_a_new_experience/logics/hero_dialog_route.dart';
import 'package:bon_voyage_a_new_experience/models/post.dart';
import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post/commentlist.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post/navigateToMapButton.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post/newcomment.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post/pin_button.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post/poststat.dart';
import 'package:bon_voyage_a_new_experience/screens/side_screen/traveler_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_screen.dart';

class PostCard extends StatefulWidget {
  final Post memory;
  final User viewer;

  PostCard({this.memory, this.viewer});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isPinned = false;

  void _like() async {
    final postData = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.memory.postId)
        .get();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.memory.postId)
        .update({
      'likers': !postData['likers'].contains(widget.viewer.userId)
          ? (postData['likers']..add(widget.viewer.userId))
          : (postData['likers']
            ..removeWhere((id) => id == widget.viewer.userId))
    });
  }

  void _addComment(String text) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.memory.postId)
        .collection('comments')
        .add(
      {
        'content': text,
        'creator': widget.viewer.userId,
        'timestamp': Timestamp.now(),
        'likers': [],
      },
    );
  }

  void _startAddNewComment(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewComment(_addComment);
      },
    );
  }

  void _deleteComment(String commentId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.memory.postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  void _deletePost() async {
    print('deletePost - initialised');
    Navigator.of(context).push(
      HeroDialogRoute(
        builder: (context) {
          return _deletePostPopupCard(
            memory: widget.memory,
            transferPost: _addPostToArchive,
            tag: '_deletePostConfirmation ${widget.memory.postId}',
          );
        },
      ),
    );
  }

  Future<void> _addPostToArchive() async {
    final User currentUser =
        Provider.of<CurrentUser>(context, listen: false).user;
    final archive = FirebaseFirestore.instance
        .collection('archive')
        .doc(currentUser.userId);
    final archiveData = await archive.get();
    var newPost;
    if (archiveData['posts'] == null) {
      newPost = [
        {widget.memory.creator.userId: widget.memory.postId}
      ];
    } else {
      newPost = [...archiveData['posts']];
      newPost.add(widget.memory.postId);
    }
    archive.update({
      'posts': newPost,
    }).then((_) async {
      print('update to archive done');
      final userFirebase = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.userId);
      final currentUserData = await userFirebase.get();
      final newPost = [...currentUserData['posts']]
        ..removeWhere((postId) => postId == widget.memory.postId);
      userFirebase.update({
        'posts': newPost,
      }).then((_) async {
        print('update to user done');
        final postData = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.memory.postId)
            .get();
        final postComments = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.memory.postId)
            .collection('comments')
            .get();

        // adding post data to public archive
        await FirebaseFirestore.instance
            .collection('archive')
            .doc('public')
            .collection('posts')
            .doc(widget.memory.postId)
            .set(postData.data());
        // adding comments to the post in public archive
        postComments.docs.forEach(
          (comment) async {
            await FirebaseFirestore.instance
                .collection('archive')
                .doc('public')
                .collection('posts')
                .doc(widget.memory.postId)
                .collection('comments')
                .doc(comment.id)
                .set(comment.data());
          },
        );

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.memory.postId)
            .delete();
        print('deletion done');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final Image postImageRef = widget.memory.imageURL == null
        ? Image.asset('./assets/images/dummy_user.png')
        : Image.network(
            widget.memory.imageURL,
          );
    // change this line when connecting to backend
    // _isPinned = false;
    return Card(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final userData = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.memory.creator.userId)
                            .get();
                        User user = User(
                          userId: widget.memory.creator.userId,
                          username: userData['username'],
                          name: userData['name'],
                          imageURL: userData['imageUrl'],
                          followers: userData['followers'],
                          followings: userData['followings'],
                          memories: userData['posts'],
                          chats: userData['chats'],
                        );
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero)
                                    .animate(animation),
                                child: child,
                              );
                            },
                            pageBuilder: (context, animation, animationTime) {
                              return TravelerProfileScreen(
                                user: user,
                                currentUser: widget.viewer,
                              );
                            },
                            transitionDuration: Duration(milliseconds: 200),
                          ),
                        );
                      },
                      padding: EdgeInsets.all(0),
                      icon: CircleAvatar(
                        backgroundImage: widget.memory.creator.imageURL == null
                            ? AssetImage('./assets/images/dummy_user.png')
                            : NetworkImage(widget.memory.creator.imageURL),
                      ),
                    ),
                    SizedBox(
                      width: mediaQuery.size.width * 0.05,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.memory.creator.name,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(widget.memory.creator.username,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    NavigateToMapButton(
                      memory: widget.memory,
                    ),
                    PinButton(
                      memory: widget.memory,
                    ),
                    PopupMenuButton(
                      onSelected: (selectedValue) async {
                        print(selectedValue);
                        switch (selectedValue) {
                          case 0:
                            // edit
                            break;
                          case 1:
                            // delete
                            _deletePost();
                            break;
                          default:
                        }
                      },
                      icon: Icon(Icons.more_horiz),
                      itemBuilder: (_) => [
                        if (widget.viewer.userId ==
                            widget.memory.creator.userId)
                          PopupMenuItem(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Edit post'),
                                  Icon(Icons.edit),
                                ],
                              ),
                              value: 0),
                        if (widget.viewer.userId ==
                            widget.memory.creator.userId)
                          PopupMenuItem(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delete post'),
                                Icon(Icons.delete),
                              ],
                            ),
                            value: 1,
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            height: mediaQuery.size.height * 0.06,
            child: Text(
              widget.memory.caption,
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: postImageRef.height,
            width: mediaQuery.size.width,
            child: widget.memory.imageURL == null
                ? Container()
                : Image.network(
                    widget.memory.imageURL,
                    fit: BoxFit.contain,
                  ),
          ),
          PostStat(widget.memory, _like, _startAddNewComment),
          Container(
            color: Theme.of(context).primaryColor,
            height: mediaQuery.size.height * 0.2,
            child: CommentList(widget.memory, _deleteComment),
          )
        ],
      ),
    );
  }
}

class _deletePostPopupCard extends StatelessWidget {
  final Post memory;
  final Future<void> Function() transferPost;
  final String tag;

  _deletePostPopupCard(
      {@required this.memory,
      @required this.tag,
      @required this.transferPost,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: tag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Material(
            color: Colors.white,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Text('Are you sure you want to delete this post?'),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        FlatButton(
                          onPressed: () async {
                            await transferPost()
                                .then((_) => Navigator.of(context).pop());
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
