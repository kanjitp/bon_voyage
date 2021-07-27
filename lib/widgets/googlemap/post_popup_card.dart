import 'dart:typed_data';

import 'package:bon_voyage_a_new_experience/logics/custom_rect_tween.dart';
import 'package:bon_voyage_a_new_experience/models/post.dart';
import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/providers/file_provider.dart';
import 'package:bon_voyage_a_new_experience/providers/taggedUsers.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/post_screen.dart';
import 'package:bon_voyage_a_new_experience/screens/post_screen/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class PostPopupCard extends StatelessWidget {
  LatLng latlng;
  Uint8List screenshotData;

  PostPopupCard({this.latlng, this.screenshotData});

  static const String _postPopup = 'post-popup';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _postPopup,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Material(
            color: Colors.white,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Text(
                    'Create a post at \n (${latlng.latitude.toStringAsFixed(4)}, ${latlng.longitude.toStringAsFixed(4)})?',
                    textAlign: TextAlign.center,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        FlatButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                            begin: const Offset(-1.0, 0.0),
                                            end: Offset.zero)
                                        .animate(animation),
                                    child: child,
                                  );
                                },
                                pageBuilder:
                                    (context, animation, animationTime) {
                                  Provider.of<FileProvider>(context,
                                          listen: false)
                                      .reset(id: CreatePostScreen.id);
                                  Provider.of<TaggedUsers>(context,
                                          listen: false)
                                      .reset(id: CreatePostScreen.id);
                                  return CreatePostScreen(
                                    latlng: latlng,
                                    screenshotData: screenshotData,
                                  );
                                },
                                transitionDuration: Duration(milliseconds: 200),
                              ),
                            );
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ]),
                  Container(
                      width: 300,
                      height: 300,
                      child: Image.memory(
                        screenshotData,
                        fit: BoxFit.fitWidth,
                      )),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
