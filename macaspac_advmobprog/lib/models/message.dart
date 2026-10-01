import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.createdAt,
    this.updatedAt,
  });

  factory ChatUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final name = (data['name'] ?? '').toString().trim();
    final email = (data['email'] ?? '').toString().trim();

    return ChatUser(
      uid: doc.id,
      name: name.isNotEmpty
          ? name
          : (email.isNotEmpty ? email.split('@').first : 'User'),
      email: email,
      photoUrl: (data['photoUrl'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;
  final String status;
  final bool isFromCurrentUser;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    required this.status,
    required this.isFromCurrentUser,
  });

  factory ChatMessage.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String currentUserId,
  }) {
    final data = doc.data() ?? <String, dynamic>{};
    final senderId = (data['senderId'] ?? '').toString();
    final receiverId = (data['receiverId'] ?? '').toString();
    final text = (data['text'] ?? '').toString();
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return ChatMessage(
      id: doc.id,
      chatId: (data['chatId'] ?? '').toString(),
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: createdAt,
      status: (data['status'] ?? 'sent').toString(),
      isFromCurrentUser: senderId == currentUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
