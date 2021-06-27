import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:bon_voyage_a_new_experience/models/fill_outline_button.dart';
import 'package:bon_voyage_a_new_experience/providers/chats.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/providers/users.dart';
import 'package:bon_voyage_a_new_experience/screens/add_chat_screen.dart';
import 'package:bon_voyage_a_new_experience/screens/chat_screen.dart';
import 'package:bon_voyage_a_new_experience/screens/main_screen.dart';
import 'package:bon_voyage_a_new_experience/widgets/myBottomNavigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatRoomScreen extends StatefulWidget {
  List<dynamic> chats;

  ChatRoomScreen(this.chats);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  bool _isLoading = false;

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    // final currentUser = Provider.of<CurrentUser>(context).user;
    // final chatsData = currentUser.chats;

    return Scaffold(
        appBar: AppBar(
          shadowColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Chats',
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
              color: Colors.black,
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15, left: 10, right: 5, bottom: 5),
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  FillOutlineButton(
                    press: () {},
                    text: "Recent Messages",
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    child: FillOutlineButton(
                      press: () {},
                      text: "Active",
                      isFilled: true,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemBuilder: (ctx, index) {
                  return ChatCard(chat: widget.chats[index]);
                },
                itemCount: widget.chats.length,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add_alt_1),
          backgroundColor: Theme.of(context).splashColor,
          onPressed: () async {
            await Provider.of<Users>(context, listen: false).fetchUsers();
            await Provider.of<CurrentUser>(context, listen: false).update();
            Navigator.of(context).pushNamed(AddChatScreen.routeName);
          },
        ),
        // does not rebuild because the switch is called on the other side
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
              print('pressed - $value');
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.messenger), label: "Chats"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
            BottomNavigationBarItem(
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(
                      Provider.of<CurrentUser>(context).user.imageURL),
                  radius: 15,
                ),
                label: "Profile"),
          ],
        ));
  }
}

class ChatCard extends StatelessWidget {
  ChatCard({
    @required this.chat,
    Key key,
  }) : super(key: key);

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;

              var tween = Tween(begin: begin, end: end);
              var curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );

              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            },
            pageBuilder: (context, animation, animationTime) {
              return ChatScreen(chat);
            },
            transitionDuration: Duration(milliseconds: 200),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: mediaQuery.size.height * 0.02,
            horizontal: mediaQuery.size.width * 0.05),
        child: Row(
          children: <Widget>[
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(chat.image),
                ),
                // if (chat.isActive)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 3),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width * 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        'Chat last message',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.64,
              child: Text('3m ago'),
            )
          ],
        ),
      ),
    );
  }
}
