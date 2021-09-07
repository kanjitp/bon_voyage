import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import '../../../widgets/chat/new_message.dart';

import '../../../widgets/chat/messages.dart';

import '../../../../../logics/custom_rect_tween.dart';
import '../../../../../logics/hero_dialog_route.dart';

import '../../../../../models/chat.dart';
import '../../../../../models/user.dart';

import '../../../../../providers/current_user.dart';

import '../../side_screen/traveler_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen(this.chat);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
      return;
    });
    fbm.subscribeToTopic('chat');

    super.initState();
  }

  Future<void> _addChatToArchive() async {
    final User currentUser =
        Provider.of<CurrentUser>(context, listen: false).user;
    final archive = FirebaseFirestore.instance
        .collection('archive')
        .doc(currentUser.userId);
    final archiveData = await archive.get();
    var newChat;
    if (archiveData['chats'] == null) {
      newChat = [
        {widget.chat.userId: widget.chat.chatId}
      ];
    } else {
      newChat = [...archiveData['chats']];
      newChat.add({widget.chat.userId: widget.chat.chatId});
    }
    archive.update({
      'chats': newChat,
    }).then((_) {
      Chat.sendUpdate(
          chat: widget.chat,
          update_message: '${currentUser.name} left the chat');
    }).then((_) async {
      final userFirebase = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.userId);
      final currentUserData = await userFirebase.get();
      final List<Map<String, dynamic>> newChat = [...currentUserData['chats']]
        ..removeWhere((map) => map.keys.first == widget.chat.userId);
      userFirebase.update({
        'chats': newChat,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        centerTitle: true,
        leadingWidth: 56,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      final userData = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.chat.userId)
                          .get();
                      User user = User(
                        userId: widget.chat.userId,
                        username: userData['username'],
                        name: userData['name'],
                        imageURL: userData['imageUrl'],
                        followers: userData['followers'],
                        followings: userData['followings'],
                        memories: userData['posts'],
                        chats: userData['chats'],
                      );
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero)
                                  .animate(animation),
                              child: child,
                            );
                          },
                          pageBuilder: (context, animation, animationTime) {
                            return TravelerProfileScreen(
                              user: user,
                              currentUser:
                                  Provider.of<CurrentUser>(context).user,
                            );
                          },
                          transitionDuration: Duration(milliseconds: 200),
                        ),
                      );
                    },
                    padding: EdgeInsets.all(0),
                    icon: CircleAvatar(
                      backgroundImage: widget.chat.image == null
                          ? AssetImage('./assets/images/dummy_user.png')
                          : NetworkImage(widget.chat.image),
                    ),
                  ),
                  if (widget.chat.isActive)
                    Positioned(
                      left: 0,
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
              SizedBox(
                width: mediaQuery.size.width * 0.05,
              ),
              Column(
                children: <Widget>[
                  Text(
                    widget.chat.name,
                    style: TextStyle(fontSize: 16),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('status')
                        .doc(widget.chat.userId)
                        .snapshots(),
                    builder: (context, statusSnapshot) {
                      if (!statusSnapshot.hasData) {
                        return Container();
                      } else {
                        return Text(
                          statusSnapshot.data['state'] == 'online'
                              ? 'Online'
                              : 'Active ${timeago.format(statusSnapshot.data['last_changed'].toDate())}',
                          style: TextStyle(fontSize: 12),
                        );
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (selectedValue) async {
              Navigator.of(context).push(
                HeroDialogRoute(
                  builder: (context) {
                    return _leaveChatPopupCard(
                      chat: widget.chat,
                      transferChat: _addChatToArchive,
                      tag: '$_leaveChatConfirmation ${widget.chat.userId}',
                    );
                  },
                ),
              );
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Leave chat'),
                      Icon(Icons.exit_to_app_rounded),
                    ],
                  ),
                  value: 1),
            ],
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Messages(chat: widget.chat),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey))),
              child: NewMessage(chat: widget.chat),
            ),
          ],
        ),
      ),
    );
  }
}

const String _leaveChatConfirmation = 'leave-chat-confirm';

// ignore: camel_case_types
class _leaveChatPopupCard extends StatelessWidget {
  final Chat chat;
  final Future<void> Function() transferChat;
  final String tag;

  const _leaveChatPopupCard(
      {@required this.chat,
      @required this.tag,
      @required this.transferChat,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: tag,
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
                  Text('Leave your chat with ${chat.username}?'),
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
                            await transferChat()
                                .then((_) => Navigator.of(context).pop())
                                .then((_) => Navigator.of(context).pop());
                          },
                          child: const Text(
                            'Leave',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
