import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/current_user.dart';

class PinButton extends StatefulWidget {
  final String postId;
  PinButton({this.postId, Key key}) : super(key: key);

  @override
  _PinButtonState createState() => _PinButtonState();
}

class _PinButtonState extends State<PinButton> {
  bool _isPinned;

  Future<void> _togglePin() async {
    final currentUser = Provider.of<CurrentUser>(context, listen: false).user;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.userId)
        .get();
    bool isPinned = userData['pinned_posts'].contains(widget.postId);
    if (isPinned) {
      final newPinnedPost = userData['pinned_posts']..remove(widget.postId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.userId)
          .update({'pinned_posts': newPinnedPost});
    } else {
      final newPinnedPost = userData['pinned_posts']..add(widget.postId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.userId)
          .update({'pinned_posts': newPinnedPost});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context, listen: false).user;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.userId)
          .snapshots(),
      builder: (ctx, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Container();
        } else {
          _isPinned = userSnapshot.data['pinned_posts'].contains(widget.postId);
          return IconButton(
            onPressed: () async {
              await _togglePin();
            },
            icon: _isPinned
                ? Icon(
                    Icons.push_pin,
                    color: Theme.of(context).accentColor,
                  )
                : Icon(Icons.push_pin, color: Colors.black38),
          );
        }
      },
    );
  }
}
