import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';

import '../providers/chats.dart';
import '../providers/current_user.dart';
import './menu_screen/chatroom_screen.dart';
import './menu_screen/feed_screen.dart';
import 'menu_screen/travelers_screen.dart';
import './menu_screen/pin_screen.dart';
import './menu_screen/profile_screen.dart';

enum Menu { myFeed, myPin, chats, travelers, profile }

class MenuScreen extends StatefulWidget {
  Menu menuType;
  User currentUser;

  int get menuIndex {
    return menuType.index;
  }

  String getTitle({menuType}) {
    switch (menuType) {
      case Menu.myFeed:
        return 'My Feed';
      case Menu.myPin:
        return 'My Pin';
      case Menu.chats:
        return 'Chats';
      case Menu.travelers:
        return 'Travelers';
      case Menu.profile:
        return currentUser.username;
      default:
        return 'Unknown';
    }
  }

  MenuScreen({@required this.menuType, @required this.currentUser, key})
      : super(key: key);

  @override
  _MenuScreenState createState() {
    return _MenuScreenState();
  }
}

class _MenuScreenState extends State<MenuScreen> {
  String _title;
  int _selectedIndex;
  List<Widget> pageList;

  @override
  void initState() {
    setState(() {
      pageList = <Widget>[
        FeedScreen(),
        PinScreen(),
        ChatRoomScreen(),
        TravelersScreen(),
        ProfileScreen(),
      ];
      this._title = widget.getTitle(menuType: widget.menuType);
      this._selectedIndex = widget.menuIndex;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          shadowColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                _title,
                textAlign: TextAlign.start,
              ),
            ],
          ),
          leading: BackButton(
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
                    return MainScreen();
                  },
                  transitionDuration: Duration(milliseconds: 200),
                ),
              );
            },
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(SettingScreen.routeName);
                },
                icon: Icon(
                  Icons.settings,
                  color: Colors.black45,
                )),
          ],
        ),
        body: pageList[_selectedIndex],
        // does not rebuild because the switch is called on the other side
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (value) async {
            switch (value) {
              case 0:
                // My feed
                break;
              case 1:
                // My Pin
                break;
              case 2:
                // Chats
                break;
              case 3:
                // Travelers
                break;
              case 4:
                // Profile
                await Provider.of<CurrentUser>(context, listen: false).update();
                break;
              default:
                break;
            }
            setState(() {
              _title = widget.getTitle(menuType: Menu.values[value]);
              _selectedIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: "My Feed"),
            BottomNavigationBarItem(
                icon: Icon(Icons.push_pin), label: "My Pin"),
            BottomNavigationBarItem(
                icon: Icon(Icons.messenger), label: "Chats"),
            BottomNavigationBarItem(
                icon: Icon(Icons.people), label: "Travelers"),
            BottomNavigationBarItem(
                icon: CircleAvatar(
                  backgroundImage:
                      Provider.of<CurrentUser>(context).user.imageURL == null
                          ? AssetImage('./assets/images/dummy_user.png')
                          : NetworkImage(
                              Provider.of<CurrentUser>(context).user.imageURL),
                  radius: 15,
                ),
                label: "Profile"),
          ],
        ));
  }
}
