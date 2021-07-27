import 'package:bon_voyage_a_new_experience/models/post.dart';
import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class PostGridItem extends StatelessWidget {
  final Post memory;
  const PostGridItem({this.memory, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: GridTile(
        child: GestureDetector(
          onTap: () async {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  );
                },
                pageBuilder: (context, animation, animationTime) {
                  final currentUser = Provider.of<CurrentUser>(context).user;
                  return PostScreen(
                      memory: Post(
                        postId: memory.postId,
                        creator: memory.creator,
                        imageURL: memory.imageURL,
                        caption: memory.caption,
                        latlng: memory.latlng,
                        likers: memory.likers,
                        taggedUsers: memory.taggedUsers,
                        comments: memory.comments,
                        isLikedByUser:
                            memory.likers.contains(currentUser.userId),
                      ),
                      viewer: currentUser);
                },
                transitionDuration: Duration(milliseconds: 200),
              ),
            );
          },
          child: Image.network(
            memory.imageURL,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
