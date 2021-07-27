import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/taggedUsers.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaggedList extends StatefulWidget {
  List<User> taggedUsers;
  Function update;

  TaggedList({this.taggedUsers, this.update});

  @override
  _TaggedListState createState() => _TaggedListState();
}

class _TaggedListState extends State<TaggedList> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return ListView.builder(
      itemBuilder: (ctx, index) {
        return Card(
            color: Colors.amber[200],
            margin: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5,
            ),
            child: ListTile(
              leading: Container(
                width: mediaQuery.size.height * 0.06,
                height: mediaQuery.size.height * 0.06,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(widget.taggedUsers[index].imageURL),
                      fit: BoxFit.fill),
                ),
              ), //profilepic
              title: Text(
                widget.taggedUsers[index].username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ), //username as title
              subtitle: Text(widget.taggedUsers[index].name),
              trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Provider.of<TaggedUsers>(context, listen: false).removeFrom(
                        user: widget.taggedUsers[index],
                        id: CreatePostScreen.id);
                    widget.update();
                  }),
            ));
      },
      itemCount: widget.taggedUsers.length,
    );
  }
}
