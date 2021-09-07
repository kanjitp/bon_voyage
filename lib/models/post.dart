import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/user.dart';

class Post {
  String postId;
  User creator;
  String imageURL;
  String caption;
  List<dynamic> likers;
  List<dynamic> comments;
  List<dynamic> taggedUsers;
  bool isLikedByUser;
  LatLng latlng; // for short circuiting

  Post(
      {this.postId,
      this.creator,
      this.imageURL,
      this.caption,
      this.likers,
      this.latlng,
      this.comments,
      this.taggedUsers,
      this.isLikedByUser});
}
