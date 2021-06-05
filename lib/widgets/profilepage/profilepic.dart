import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final length = MediaQuery.of(context).size.width * 0.28;
    return Container(
        width: length,
        height: length,
        child:
            Image.asset('assets/images/BenjaminWalker.png', fit: BoxFit.cover));
  }
}
