import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class Chat {
  final String name, username, userId, lastmessage, image, chatId;
  final Timestamp timestamp;
  final bool isActive;

  Chat({
    this.userId,
    this.username,
    this.name,
    this.chatId,
    this.lastmessage,
    this.image,
    this.timestamp,
    this.isActive,
  });

  static void sendUpdate({Chat chat, String update_message}) async {
    final currentUser = await auth.FirebaseAuth.instance.currentUser;
    final timestamp = Timestamp.now();
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.chatId)
        .collection('messages')
        .add(
      {
        'text': '${chat.chatId} update',
        'update_message': update_message,
        'timestamp': timestamp,
        'userId': currentUser.uid,
      },
    );
    final chatRoomData = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.chatId)
        .get();
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.chatId)
        .update({
      'user1': chatRoomData['user1'],
      'user2': chatRoomData['user2'],
      'timestamp': timestamp,
      'lastmessage': update_message,
    });
  }
}
