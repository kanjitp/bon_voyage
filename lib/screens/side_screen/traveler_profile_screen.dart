import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/screens/menu_screen/chat/chat_screen.dart';
import 'package:bon_voyage_a_new_experience/screens/menu_screen/profile_screen.dart';
import 'package:bon_voyage_a_new_experience/widgets/bonVoyageMap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TravelerProfileScreen extends StatefulWidget {
  final User user;
  final User currentUser;

  TravelerProfileScreen(
      {@required this.user, @required this.currentUser, Key key})
      : super(key: key);

  @override
  _TravelerProfileScreenState createState() => _TravelerProfileScreenState();
}

class _TravelerProfileScreenState extends State<TravelerProfileScreen> {
  bool initiallyFollowed;
  bool isFollowed;
  bool havetoUpdateDatabase = false;

  @override
  void initState() {
    isFollowed = widget.user.followers.contains(widget.currentUser.userId);
    initiallyFollowed = isFollowed;
    print('isFollowed $isFollowed');
    super.initState();
  }

  Future<String> _addChatDataToUsers(
      String userId, String anotherUserId) async {
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final anotherUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(anotherUserId)
        .get();

    final chatRoomData =
        await FirebaseFirestore.instance.collection('chats').add({
      'user1': userId,
      'user2': anotherUserId,
      'lastmessage': "",
      'timestamp': Timestamp.now(),
    });

    final chatRoomId = chatRoomData.id;

    // initialised
    List<Map<String, dynamic>> newUserChats;
    print(userData);

    if (!userData.data().containsKey('chats')) {
      newUserChats = [
        {anotherUserId: chatRoomId}
      ];
    } else {
      newUserChats = [...userData['chats']];
      newUserChats.add({anotherUserId: chatRoomId});
    }

    List<Map<String, dynamic>> newAnotherUserChats;

    if (!anotherUserData.data().containsKey('chats')) {
      newAnotherUserChats = [
        {userId: chatRoomId}
      ];
    } else {
      newAnotherUserChats = [...anotherUserData['chats']];
      newAnotherUserChats.add({userId: chatRoomId});
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).update(
      {
        'chats': newUserChats,
      },
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(anotherUserId)
        .update(
      {
        'chats': newAnotherUserChats,
      },
    );
    return chatRoomId;
  }

  void _followAndUnfollow() {
    setState(() {
      isFollowed = !isFollowed;
      havetoUpdateDatabase = !havetoUpdateDatabase;
    });
  }

  void updateDatabase() async {
    print('updateDatabase - initialised');
    final _firestore = FirebaseFirestore.instance;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.userId)
        .get();
    List newFollowers;
    if (userData['followers'].contains(widget.currentUser.userId)) {
      newFollowers = [...userData['followers']];
      newFollowers.remove(widget.currentUser.userId);
    } else {
      newFollowers = [...userData['followers'], widget.currentUser.userId];
    }
    _firestore.collection('users').doc(widget.user.userId).update({
      'followers': newFollowers,
    });
    final currentUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.userId)
        .get();

    List newFollowings;
    if (currentUserData['followings'].contains(widget.user.userId)) {
      newFollowings = [...currentUserData['followings']];
      newFollowings.remove(widget.user.userId);
    } else {
      newFollowings = [...currentUserData['followings'], widget.user.userId];
    }

    _firestore.collection('users').doc(widget.currentUser.userId).update({
      'followings': newFollowings,
    });
    print('updateDatabase - completed');
    // re-render
    setState(() {
      havetoUpdateDatabase = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final appBar = PreferredSize(
      preferredSize: Size.fromHeight(mediaQuery.size.height * 0.075),
      child: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.user.username,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: BackButton(
          onPressed: () async {
            if (havetoUpdateDatabase) {
              updateDatabase();
            }
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFFF7CA56),
        elevation: 0,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: appBar,
      body: widget.currentUser.userId == widget.user.userId
          ? ProfileScreen()
          : TravelerProfileBody(
              user: widget.user,
              addChat: _addChatDataToUsers,
              followAndUnfollow: _followAndUnfollow,
              isFollowed: isFollowed,
              havetoUpdateDatabase: havetoUpdateDatabase,
              updateDatabase: updateDatabase,
              initiallyFollowed: initiallyFollowed,
            ),
    );
  }
}

class TravelerProfileBody extends StatefulWidget {
  final User user;
  final Function addChat;
  final Function followAndUnfollow;
  final Function updateDatabase;
  bool isFollowed;
  bool havetoUpdateDatabase;
  final bool initiallyFollowed;

  TravelerProfileBody({
    @required User this.user,
    @required this.addChat,
    @required this.followAndUnfollow,
    @required this.isFollowed,
    @required this.havetoUpdateDatabase,
    @required this.updateDatabase,
    @required this.initiallyFollowed,
    Key key,
  }) : super(key: key);

  @override
  _TravelerProfileBodyState createState() => _TravelerProfileBodyState();
}

class _TravelerProfileBodyState extends State<TravelerProfileBody> {
  ProfileMode currentMode = ProfileMode.map;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final currentUser = Provider.of<CurrentUser>(context).user;
    return SafeArea(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.125,
                          backgroundColor: Colors.grey,
                          backgroundImage: widget.user.imageURL == null
                              ? AssetImage('./assets/images/dummy_user.png')
                              : NetworkImage(widget.user.imageURL),
                        ),
                        SizedBox(
                          height: mediaQuery.size.height * 0.01,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.name,
                                style: TextStyle(
                                  color: Color(0xFF282728),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 23,
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.005),
                              Text(
                                '@' + widget.user.username,
                                style: TextStyle(
                                  color: Color(0xFF485777),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.025),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.user.memories.length.toString(),
                                    style: TextStyle(
                                      color: Color(0xFF485777),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mediaQuery.size.height * 0.005,
                                  ),
                                  Text(
                                    'Memories',
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: mediaQuery.size.width * 0.10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        (widget.initiallyFollowed
                                                ? widget.havetoUpdateDatabase
                                                    ? widget.user.followers
                                                            .length -
                                                        1
                                                    : widget
                                                        .user.followers.length
                                                : widget.havetoUpdateDatabase
                                                    ? widget.user.followers
                                                            .length +
                                                        1
                                                    : widget
                                                        .user.followers.length)
                                            .toString(),
                                        style: TextStyle(
                                          color: Color(0xFF485777),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(
                                        width: mediaQuery.size.width * 0.02,
                                      ),
                                      Text(
                                        'Followers',
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: mediaQuery.size.height * 0.015),
                                  Row(
                                    children: [
                                      Text(
                                        widget.user.followings.length
                                            .toString(),
                                        style: TextStyle(
                                          color: Color(0xFF485777),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(
                                        width: mediaQuery.size.width * 0.02,
                                      ),
                                      Text(
                                        'Following',
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        height: mediaQuery.size.height * 0.03,
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            widget.followAndUnfollow();
                          },
                          child: widget.isFollowed
                              ? Text(
                                  'Following',
                                )
                              : Text('Follow'),
                          style: widget.isFollowed
                              ? ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent))
                              : ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blueGrey)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: mediaQuery.size.height * 0.03,
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            String chatId;
                            bool haveChat = false;

                            // check for already available chat
                            for (var map in currentUser.chats) {
                              if (map.containsKey(widget.user.userId)) {
                                print(
                                    'travelerProfileScreen - found existing chat');
                                chatId = map[widget.user.userId];
                                haveChat = true;
                              }
                            }
                            // chat doesn't exit yet - create new one
                            if (!haveChat) {
                              print(
                                  'travelerProfileScreen - did not find any chat');
                              print('initiating new chatroom ...');
                              chatId = await widget.addChat(
                                  currentUser.userId, widget.user.userId);
                            }
                            final statusData = await FirebaseFirestore.instance
                                .collection('status')
                                .doc(widget.user.userId)
                                .get();

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                                pageBuilder:
                                    (context, animation, animationTime) {
                                  return ChatScreen(Chat(
                                    chatId: chatId,
                                    name: widget.user.name,
                                    userId: widget.user.userId,
                                    username: widget.user.username,
                                    image: widget.user.imageURL,
                                    isActive: statusData['state'] == 'online' ||
                                        (statusData['state'] == 'offline' &&
                                            DateTime.now()
                                                .subtract(Duration(minutes: 5))
                                                .isBefore(
                                                    statusData['last_changed']
                                                        .toDate())),
                                  ));
                                },
                                transitionDuration: Duration(milliseconds: 200),
                              ),
                            );
                          },
                          child: Text(
                            'Message',
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent)),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  widget.user.name == null
                      ? 'pending'
                      : widget.user.name + '\'s Map',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Dummy icon button for now
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                          icon: currentMode == ProfileMode.map
                              ? Icon(
                                  Icons.location_on_rounded,
                                  color: Theme.of(context).splashColor,
                                )
                              : Icon(Icons.location_on_rounded),
                          onPressed: () {
                            setState(() {
                              currentMode = ProfileMode.map;
                            });
                          }),
                      SizedBox(
                        width: mediaQuery.size.width * 0.02,
                      ),
                      IconButton(
                          icon: currentMode == ProfileMode.memories
                              ? Icon(
                                  Icons.grid_on_rounded,
                                  color: Theme.of(context).splashColor,
                                )
                              : Icon(Icons.grid_on_rounded),
                          onPressed: () {
                            setState(() {
                              currentMode = ProfileMode.memories;
                            });
                          }),
                      SizedBox(
                        width: mediaQuery.size.width * 0.02,
                      ),
                      IconButton(
                          icon: currentMode == ProfileMode.tagged
                              ? Icon(
                                  Icons.supervised_user_circle_outlined,
                                  color: Theme.of(context).splashColor,
                                )
                              : Icon(Icons.supervised_user_circle_outlined),
                          onPressed: () {
                            setState(() {
                              currentMode = ProfileMode.tagged;
                            });
                          })
                    ])
              ],
            ),
            if (currentMode == ProfileMode.map)
              Expanded(
                child: BonVoyageMap(
                  allowPost: false,
                ),
              ),
            if (currentMode == ProfileMode.memories)
              Expanded(child: Container()),
            if (currentMode == ProfileMode.tagged) Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
