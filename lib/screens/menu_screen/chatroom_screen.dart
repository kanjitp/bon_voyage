import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:bon_voyage_a_new_experience/models/fill_outline_button.dart';
import 'package:bon_voyage_a_new_experience/providers/chats.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/providers/users.dart';
import 'package:bon_voyage_a_new_experience/screens/add_chat_screen.dart';
import 'package:bon_voyage_a_new_experience/screens/menu_screen/chat/chat_screen.dart';
import 'package:bon_voyage_a_new_experience/screens/main_screen.dart';
import 'package:bon_voyage_a_new_experience/widgets/myBottomNavigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatRoomScreen extends StatefulWidget {
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  void _refreshChats() async {
    setState(() {
      Provider.of<Chats>(context).fetchChats();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context).user;
    return Container(
      child: Column(
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
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  final List<dynamic> chatMaps = snapshot.data['chats'];
                  List<dynamic> userIds = [];
                  List<dynamic> chatIds = [];
                  chatMaps.forEach((chatmap) {
                    final userId = chatmap.keys.first;
                    userIds.add(userId);
                    chatIds.add(chatmap[userId]);
                  });
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: chatIds.length,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemBuilder: (ctx, index) {
                      var userId = userIds[index];
                      var chatId = chatIds[index];
                      return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .snapshots(),
                          builder: (ctx, chatSnapshot) {
                            if (!chatSnapshot.hasData) {
                              return CircularProgressIndicator();
                            } else {
                              return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .snapshots(),
                                  builder: (ctx, userSnapshot) {
                                    if (!userSnapshot.hasData) {
                                      return CircularProgressIndicator();
                                    } else {
                                      return ChatCard(
                                        chat: Chat(
                                          chatId: chatId,
                                          lastmessage:
                                              chatSnapshot.data['lastmessage'],
                                          timestamp:
                                              chatSnapshot.data['timestamp'],
                                          name: userSnapshot.data['name'],
                                          image: userSnapshot.data['imageUrl'],
                                        ),
                                      );
                                    }
                                  });
                            }
                          });
                    },
                  );
                }
              }),
        ],
      ),
    );
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
    final timepast =
        timeago.format(chat.timestamp.toDate(), locale: 'en_short');
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: chat.image == null
                      ? AssetImage('./assets/images/dummy_user.png')
                      : NetworkImage(chat.image),
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
                        chat.lastmessage,
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
              child: Text(timepast == 'now' ? timepast : '$timepast ago'),
            )
          ],
        ),
      ),
    );
  }
}
