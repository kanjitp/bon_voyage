import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_tag/edit_tag_screen.dart';

import '../../../providers/taggedUsers.dart';
import './create_post_screen.dart';

class CreateTag extends StatefulWidget {
  @override
  _CreateTagState createState() => _CreateTagState();
}

class _CreateTagState extends State<CreateTag> {
  void updateCreatePost() {
    setState(() {
      // re-render
      print('re-rendered');
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final taggedUsers =
        Provider.of<TaggedUsers>(context).of(id: CreatePostScreen.id);
    final tagString = taggedUsers.fold<String>(
        '', (previousValue, element) => '$previousValue @${element.username}');
    return Container(
      height: mediaQuery.size.height * 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Tagged',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              if (taggedUsers.isEmpty)
                Text(
                  'none',
                  style: TextStyle(color: Colors.black38),
                ),
              if (!taggedUsers.isEmpty)
                Text(tagString,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ))
            ],
          ),
          FlatButton(
            minWidth: mediaQuery.size.width * 0.3,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
                  pageBuilder: (context, animation, animationTime) {
                    return EditTagScreen(updateCreatePost);
                  },
                  transitionDuration: Duration(milliseconds: 200),
                ),
              );
            },
            color: Theme.of(context).accentColor,
            child: Text('Edit Tag', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
