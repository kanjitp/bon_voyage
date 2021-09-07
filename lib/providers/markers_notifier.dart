import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/user.dart';

import '../providers/current_user.dart';

import '../screens/post_screen/post_screen.dart';

class MarkersNotifier with ChangeNotifier {
  List<Marker> _markers = [];

  List<Marker> get markers {
    return (<Marker>[..._markers]);
  }

  void add(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void remove(Marker marker) {
    _markers.removeWhere((m) => marker.markerId == m.markerId);
    notifyListeners();
  }

  void runFetchPostMarkers(BuildContext context) async {
    // refresh
    _markers = [];
    FirebaseFirestore.instance.collection('posts').snapshots().forEach(
      (postsSnapshot) {
        postsSnapshot.docs.forEach(
          (postSnapshot) {
            if (!_markers.any(
                (marker) => marker.markerId.toString() == postSnapshot.id)) {
              add(
                Marker(
                  onTap: () async {
                    final User creator =
                        await User.getUserFromId(postSnapshot['creator']);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                                    begin: const Offset(0.0, 1.0),
                                    end: Offset.zero)
                                .animate(animation),
                            child: child,
                          );
                        },
                        pageBuilder: (context, animation, animationTime) {
                          final currentUser =
                              Provider.of<CurrentUser>(context).user;
                          return PostScreen(
                              memory: Post(
                                postId: postSnapshot.id,
                                creator: creator,
                                imageURL: postSnapshot['imageUrl'],
                                caption: postSnapshot['caption'],
                                latlng: LatLng(
                                    postSnapshot['lat'], postSnapshot['lng']),
                                likers: postSnapshot['likers'],
                                taggedUsers: postSnapshot['tagged_users'],
                                comments: postSnapshot['comments'],
                                isLikedByUser: postSnapshot['likers']
                                    .contains(currentUser.userId),
                              ),
                              viewer: currentUser);
                        },
                        transitionDuration: Duration(milliseconds: 200),
                      ),
                    );
                  },
                  markerId: MarkerId(postSnapshot.id),
                  position: LatLng(postSnapshot['lat'], postSnapshot['lng']),
                ),
              );
            }
          },
        );
      },
    );
    print('runFetchMarkers - completed');
  }
}
