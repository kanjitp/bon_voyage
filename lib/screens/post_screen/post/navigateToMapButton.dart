import 'package:bon_voyage_a_new_experience/models/post.dart';
import 'package:flutter/material.dart';

import '../../main_screen.dart';

class NavigateToMapButton extends StatelessWidget {
  final Post memory;

  NavigateToMapButton({this.memory});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(-1.0, 0.0), end: Offset.zero)
                    .animate(animation),
                child: child,
              );
            },
            pageBuilder: (context, animation, animationTime) {
              return MainScreen(memory.latlng, true);
            },
            transitionDuration: Duration(milliseconds: 200),
          ),
        );
      },
      color: Theme.of(context).accentColor,
      icon: Icon(Icons.public),
      tooltip:
          '(${memory.latlng.latitude.toStringAsFixed(4)}, ${memory.latlng.longitude.toStringAsFixed(4)})',
    );
  }
}
