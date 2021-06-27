import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/current_user.dart';

class ProfilePic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageUrl = Provider.of<CurrentUser>(context).user.imageURL;
    return CircleAvatar(
      radius: MediaQuery.of(context).size.width * 0.125,
      backgroundColor: Colors.grey,
      backgroundImage: imageUrl == null
          ? AssetImage('./assets/images/dummy_user.png')
          : NetworkImage(imageUrl),
    );
  }
}
