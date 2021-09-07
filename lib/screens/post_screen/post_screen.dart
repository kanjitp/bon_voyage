import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './post/navigateToMapButton.dart';
import './post/pin_button.dart';
import './post/commentlist.dart';
import './post/newcomment.dart';
import './post/poststat.dart';

import '../side_screen/traveler_profile_screen.dart';

import '../../../models/post.dart';
import './../../models/user.dart';

class PostScreen extends StatefulWidget {
  final User viewer;

  PostScreen({@required this.memory, @required this.viewer});
  final Post memory;

  @override
  _PostScreenState createState() {
    return _PostScreenState();
  }
}

class _PostScreenState extends State<PostScreen> {
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

    final appBar = PreferredSize(
      preferredSize: Size.fromHeight(mediaQuery.size.height * 0.075),
      child: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
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
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
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
                      style: TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              )
            ],
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (selectedValue) async {
              switch (selectedValue) {
                case 0:
                  break;
                case 1:
                  break;
                default:
              }
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              if (widget.viewer.userId == widget.memory.creator.userId)
                PopupMenuItem(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Edit post'),
                        Icon(Icons.edit),
                      ],
                    ),
                    value: 1),
              if (widget.viewer.userId == widget.memory.creator.userId)
                PopupMenuItem(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delete post'),
                      Icon(Icons.delete),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: appBar,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PostStat(widget.memory.postId, _like, _startAddNewComment),
                Row(
                  children: [
                    NavigateToMapButton(
                      memory: widget.memory,
                    ),
                    PinButton(postId: widget.memory.postId),
                  ],
                )
              ],
            ),
            SizedBox(
              height: mediaQuery.size.height * 0.025,
            ),
            Container(
              //Caption
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.only(
                  left: mediaQuery.size.width * 0.05,
                  right: mediaQuery.size.width * 0.05),
              child: FittedBox(
                child: Text(
                  widget.memory.caption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
                padding: EdgeInsets.symmetric(
                    vertical: mediaQuery.size.height * 0.02),
                height: mediaQuery.size.height * 0.25,
                child: CommentList(widget.memory.postId, widget.memory.creator,
                    _deleteComment)),
          ],
        ),
      ),
    );
  }
}
