import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final currentIndex;

  MyBottomNavigationBar({
    @required this.currentIndex,
    Key key,
  }) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex;

  @override
  Widget build(BuildContext context) {
    _selectedIndex = widget.currentIndex;
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
          print('pressed - $value');
        });
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.messenger), label: "Chats"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
        BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage:
                  NetworkImage(Provider.of<CurrentUser>(context).user.imageURL),
              radius: 15,
            ),
            label: "Profile"),
      ],
    );
  }
}
