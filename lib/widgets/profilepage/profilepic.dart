import 'package:bon_voyage/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageUrl = Provider.of<CurrentUser>(context).imageUrl;
    return CircleAvatar(
      radius: MediaQuery.of(context).size.width * 0.125,
      backgroundColor: Colors.grey,
      backgroundImage: imageUrl == null
          ? AssetImage('./assets/images/dummy_user.png')
          : NetworkImage(imageUrl),
    );
  }
}
