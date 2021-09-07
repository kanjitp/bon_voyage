import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../logics/custom_rect_tween.dart';
import '../../.../../logics/hero_dialog_route.dart';

import '../../../../models/chat.dart';

import '../../../../widgets/fill_outline_button.dart';

import '../../../../models/user.dart';

import '../../../../providers/chats.dart';
import '../../../../providers/current_user.dart';

import './chat/chat_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

enum ChatRoomMode { recent, active, archive }

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  ChatRoomMode _mode;

  @override
  void initState() {
    super.initState();
  }

  static Future<void> restoreChat(BuildContext context, Chat chat) async {
    final User currentUser =
        Provider.of<CurrentUser>(context, listen: false).user;
    final archive = FirebaseFirestore.instance
        .collection('archive')
        .doc(currentUser.userId);
    final archiveData = await archive.get();
    var newChat;
    if (archiveData['chats'] != null) {
      newChat = [...archiveData['chats']]
        ..removeWhere((map) => map.keys.first == chat.userId);
    }

    archive.update({
      'chats': newChat,
    }).then((_) {
      Chat.sendUpdate(
          chat: chat, update_message: '${currentUser.name} rejoined the chat');
    }).then((_) async {
      final userFirebase = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.userId);
      final currentUserData = await userFirebase.get();
      final List<Map<String, dynamic>> newChat = [...currentUserData['chats']]
        ..add({chat.userId: chat.chatId});
      userFirebase.update({
        'chats': newChat,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context).user;
    _mode = Provider.of<Chats>(context).currentMode;
    return Container(
      color: Colors.white70,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10, right: 5, bottom: 5),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FillOutlineButton(
                        press: () {
                          setState(() {
                            Provider.of<Chats>(context, listen: false)
                                .setMode(ChatRoomMode.recent);
                          });
                        },
                        text: "Recent Messages",
                        isFilled: _mode == ChatRoomMode.recent),
                    SizedBox(
                      width: 8,
                    ),
                    FillOutlineButton(
                      press: () {
                        setState(() {
                          Provider.of<Chats>(context, listen: false)
                              .setMode(ChatRoomMode.active);
                        });
                      },
                      text: "Active",
                      isFilled: _mode == ChatRoomMode.active,
                    ),
                  ],
                ),
                FillOutlineButton(
                    press: () {
                      setState(() {
                        Provider.of<Chats>(context, listen: false)
                            .setMode(ChatRoomMode.archive);
                      });
                    },
                    text: "Archive",
                    isFilled: _mode == ChatRoomMode.archive),
              ],
            ),
          ),
          if (_mode == ChatRoomMode.active || _mode == ChatRoomMode.recent)
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
                                  return StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('status')
                                        .doc(userId)
                                        .snapshots(),
                                    builder: (ctx, statusSnapshot) {
                                      if (!statusSnapshot.hasData) {
                                        return Container();
                                      } else {
                                        final userIsActive = statusSnapshot
                                                    .data['state'] ==
                                                'online' ||
                                            (statusSnapshot.data['state'] ==
                                                    'offline' &&
                                                DateTime.now()
                                                    .subtract(
                                                        Duration(minutes: 5))
                                                    .isBefore(statusSnapshot
                                                        .data['last_changed']
                                                        .toDate()));
                                        final chatCard = ChatCard(
                                          turnOn: true,
                                          chat: Chat(
                                            chatId: chatId,
                                            lastmessage: chatSnapshot
                                                .data['lastmessage'],
                                            timestamp:
                                                chatSnapshot.data['timestamp'],
                                            name: userSnapshot.data['name'],
                                            username:
                                                userSnapshot.data['username'],
                                            userId: userId,
                                            image:
                                                userSnapshot.data['imageUrl'],
                                            isActive: userIsActive,
                                          ),
                                        );
                                        if (_mode == ChatRoomMode.active) {
                                          return userIsActive
                                              ? chatCard
                                              : Container();
                                        } else {
                                          return chatCard;
                                        }
                                      }
                                    },
                                  );
                                }
                              },
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          if (_mode == ChatRoomMode.archive)
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('archive')
                    .doc(currentUser.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.35),
                      child: Text(
                        'You currenlty have no archive data',
                        style: TextStyle(
                          color: Colors.black38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
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
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else {
                                    return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('status')
                                          .doc(userId)
                                          .snapshots(),
                                      builder: (ctx, statusSnapshot) {
                                        if (!statusSnapshot.hasData) {
                                          return Container();
                                        } else {
                                          final userIsActive = statusSnapshot
                                                      .data['state'] ==
                                                  'online' ||
                                              (statusSnapshot.data['state'] ==
                                                      'offline' &&
                                                  DateTime.now()
                                                      .subtract(
                                                          Duration(minutes: 5))
                                                      .isBefore(statusSnapshot
                                                          .data['last_changed']
                                                          .toDate()));
                                          final chatCard = ArchiveChatCard(
                                            chat: Chat(
                                              chatId: chatId,
                                              lastmessage: chatSnapshot
                                                  .data['lastmessage'],
                                              timestamp: chatSnapshot
                                                  .data['timestamp'],
                                              name: userSnapshot.data['name'],
                                              username:
                                                  userSnapshot.data['username'],
                                              userId: userId,
                                              image:
                                                  userSnapshot.data['imageUrl'],
                                              isActive: userIsActive,
                                            ),
                                          );
                                          return chatCard;
                                        }
                                      },
                                    );
                                  }
                                },
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                }),
        ],
      ),
    );
  }
}

class ArchiveChatCard extends StatelessWidget {
  final Chat chat;

  ArchiveChatCard({@required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return _RestoreChatPopupCard(
            chat: chat,
            tag: '$_heroRestoreChat ${this.chat.userId}',
          );
        }));
      },
      child: ChatCard(
        chat: chat,
        turnOn: false,
      ),
    );
  }
}

const String _heroRestoreChat = 'restore-chat';

class _RestoreChatPopupCard extends StatelessWidget {
  final Chat chat;
  final String tag;
  const _RestoreChatPopupCard(
      {@required this.chat, @required this.tag, Key key})
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
                  Text('Restore your chat with ${chat.username}?'),
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
                            await _ChatRoomScreenState.restoreChat(
                                    context, chat)
                                .then((_) => Navigator.of(context).pop());
                          },
                          child: const Text(
                            'Restore',
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

class ChatCard extends StatelessWidget {
  final Chat chat;
  final bool turnOn;

  ChatCard({
    @required this.chat,
    @required this.turnOn,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final timepast =
        timeago.format(chat.timestamp.toDate(), locale: 'en_short');
    Widget buildChatCard() {
      return Padding(
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
                if (chat.isActive)
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
      );
    }

    return this.turnOn
        ? InkWell(
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
            child: buildChatCard(),
          )
        : buildChatCard();
  }
}
