import 'user.dart';

class Comment {
  String content;
  User user;
  List<User> likers = [];
  bool isLikedByUser;

  Comment(this.content, this.user, this.likers, this.isLikedByUser);
}
