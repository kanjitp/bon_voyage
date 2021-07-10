import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String name, lastmessage, image, chatId;
  final Timestamp timestamp;
  final bool isActive;

  Chat({
    this.name,
    this.chatId,
    this.lastmessage,
    this.image,
    this.timestamp,
    this.isActive,
  });
}
