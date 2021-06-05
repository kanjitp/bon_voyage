import 'location.dart';
import 'post.dart';

class User {
  String userName;
  String firstName;
  String lastName;
  String bio;
  List<Post> memories;
  List<User> followers;
  List<User> followings;
  DateTime dateOfBirth;
  bool isVisible;
  double maxDistanceVisible;
  Location currentLocation;

  User(
      this.userName,
      this.firstName,
      this.lastName,
      this.bio,
      this.memories,
      this.followers,
      this.followings,
      this.dateOfBirth,
      this.isVisible,
      this.maxDistanceVisible,
      this.currentLocation);

  void setLocation(Location loc) {
    currentLocation = loc;
  }
}
