import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class Comment {
  String commendId;
  String content;
  User user;
  List<dynamic> likers = [];
  bool isLikedByUser;
  Timestamp timestamp;

  Comment(
      {this.commendId,
      this.content,
      this.user,
      this.likers,
      this.isLikedByUser,
      this.timestamp});
}
