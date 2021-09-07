import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class User {
  String username;
  String userId;
  String name;
  String bio;
  String imageURL;
  List<dynamic> chats;
  List<dynamic> memories;
  List<dynamic> taggedPosts;
  List<dynamic> pinnedPosts;
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
      this.taggedPosts,
      this.pinnedPosts,
      this.maxDistanceVisible,
      this.currentLocation});

  void setLocation(Position loc) {
    currentLocation = loc;
  }

  static Future<User> getUserFromId(String userId) async {
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return User(
      userId: userId,
      username: userData['username'],
      name: userData['name'],
      imageURL: userData['imageUrl'],
      chats: userData['chats'],
      memories: userData['posts'],
      followers: userData['followers'],
      followings: userData['followings'],
      taggedPosts: userData['tagged_posts'],
      pinnedPosts: userData['pinned_posts'],
    );
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (!(other is User)) {
      return false;
    } else {
      // ignore: test_types_in_equals
      User otherUser = other as User;
      return this.userId == otherUser.userId;
    }
  }
}
