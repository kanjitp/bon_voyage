import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './tag/tagged_list.dart';
import './tag/search_tag.dart';

import '../create_post_screen.dart';

import '../../../providers/taggedUsers.dart';

class EditTagScreen extends StatefulWidget {
  Function createPostUpdate;

  EditTagScreen(this.createPostUpdate);
  @override
  _EditTagScreenState createState() => _EditTagScreenState();
}

class _EditTagScreenState extends State<EditTagScreen> {
  void update() {
    setState(() {
      // re-render;
      print('re-rendered');
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            widget.createPostUpdate();
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Text(
              'Edit Tag',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFF7CA56),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF7CA56),
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: mediaQuery.size.height * 0.03,
            horizontal: mediaQuery.size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tagged Travellers',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: mediaQuery.size.height * 0.02),
            Container(
              height: mediaQuery.size.height * 0.4,
              child: TaggedList(
                  update: update,
                  taggedUsers: Provider.of<TaggedUsers>(context, listen: false)
                      .of(id: CreatePostScreen.id)),
            ),
            Expanded(
                child: SearchTag(
              update: update,
            ))
          ],
        ),
      ),
    );
  }
}
