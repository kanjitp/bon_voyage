import 'package:geolocator/geolocator.dart';

import 'post.dart';

class User {
  String username;
  String userId;
  String name;
  String bio;
  String imageURL;
  List<dynamic> chats;
  List<dynamic> memories;
  List<dynamic> followers;
  List<dynamic> followings;
  DateTime dateOfBirth;
  bool isVisible;
  double maxDistanceVisible;
  Position currentLocation;

  User(
      {this.username,
      this.name,
      this.bio,
      this.userId,
      this.imageURL,
      this.chats,
      this.memories,
      this.followers,
      this.followings,
      this.dateOfBirth,
      this.isVisible,
      this.maxDistanceVisible,
      this.currentLocation});

  void setLocation(Position loc) {
    currentLocation = loc;
  }

  @override
  String toString() {
    return '$this.username $this.name $this.imageURL';
  }
}
