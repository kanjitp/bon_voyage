import 'package:bon_voyage_a_new_experience/models/chat.dart';
import 'package:bon_voyage_a_new_experience/models/user.dart';
import 'package:bon_voyage_a_new_experience/providers/chats.dart';
import 'package:bon_voyage_a_new_experience/providers/current_user.dart';
import 'package:bon_voyage_a_new_experience/providers/users.dart';
import 'package:bon_voyage_a_new_experience/screens/menu_screen/chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddChatScreen extends StatefulWidget {
  static final routeName = '/add-chat';

  final Function() refreshChat;

  AddChatScreen({@required this.refreshChat, Key key}) : super(key: key);

  @override
  _AddChatScreenState createState() => _AddChatScreenState();
}

class _AddChatScreenState extends State<AddChatScreen> {
  @override
  Widget build(BuildContext context) {
    final users = Provider.of<Users>(context).usersExcludingCurrentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemBuilder: (ctx, index) {
                  return UserCard(
                    user: users[index],
                    refreshChats: widget.refreshChat,
                  );
                },
                itemCount: users.length),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  UserCard({
    this.user,
    this.refreshChats,
    Key key,
  }) : super(key: key);

  // user we want to add
  User user;
  Function refreshChats;

  Future<String> _addChatDataToUsers(User user, User anotherUser) async {
    print(user.userId);
    print(anotherUser.userId);
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.userId)
        .get();
    final anotherUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(anotherUser.userId)
        .get();

    final chatRoomData =
        await FirebaseFirestore.instance.collection('chats').add({
      'user1': user.userId,
      'user2': anotherUser.userId,
    });

    final chatRoomId = chatRoomData.id;

    // initialised
    List<String> newUserChats;
    print(userData);

    if (!userData.data().containsKey('chats')) {
      newUserChats = [chatRoomId];
    } else {
      print('reached');
      newUserChats = [...userData['chats']];
      newUserChats.add(chatRoomId);
    }

    List<String> newAnotherUserChats;

    if (!anotherUserData.data().containsKey('chats')) {
      newAnotherUserChats = [chatRoomId];
    } else {
      newAnotherUserChats = [...anotherUserData['chats']];
      newAnotherUserChats.add(chatRoomId);
    }

    await FirebaseFirestore.instance.collection('users').doc(user.userId).set(
      {
        'email': userData['email'],
        'username': userData['username'],
        'name': userData['name'],
        'imageUrl': userData['imageUrl'],
        'chats': newUserChats
      },
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(anotherUser.userId)
        .set(
      {
        'email': anotherUserData['email'],
        'username': anotherUserData['username'],
        'name': anotherUserData['name'],
        'imageUrl': anotherUserData['imageUrl'],
        'chats': newAnotherUserChats
      },
    );

    return chatRoomId;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context).user;
    final mediaQuery = MediaQuery.of(context);

    return InkWell(
      onTap: () async {
        final chatId = await _addChatDataToUsers(currentUser, user);

        Navigator.pushReplacement(
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
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .get(),
                builder: (ctx, chatRoomSnapshot) {
                  final user1Id = chatRoomSnapshot.data['user1'];
                  final user2Id = chatRoomSnapshot.data['user2'];
                  final otherUserId =
                      user1Id == currentUser.userId ? user2Id : user1Id;
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                    builder: (ctx, otherUserSnapshot) {
                      final userData = otherUserSnapshot.data;
                      return ChatScreen(
                        Chat(
                          chatId: chatId,
                          name: userData['name'],
                          image: userData['imageUrl'],
                        ),
                      );
                    },
                  );
                },
              );
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
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(user.imageURL),
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
                      user.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        '@' + user.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
