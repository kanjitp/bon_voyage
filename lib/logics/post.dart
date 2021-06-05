import 'package:flutter/material.dart';
import 'user.dart';
import 'comment.dart';

class Post {
  Image image;
  String caption;
  List<User> likers;
  List<Comment> comments;
  bool isLikedByUser; // for short circuiting

  Post(
      this.image, this.caption, this.likers, this.comments, this.isLikedByUser);
}
