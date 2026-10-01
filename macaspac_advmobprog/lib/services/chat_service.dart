import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  String buildChatId(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return ids.join('_');
  }

  Future<void> syncCurrentUserProfile({
    required String uid,
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
    if (uid.isEmpty) return;

    final profile = ChatUser(
      uid: uid,
      name: name.trim().isNotEmpty ? name.trim() : email.split('@').first,
      email: email.trim(),
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<List<ChatUser>> getUsers() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const [];
    }

    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs
        .map(ChatUser.fromDocument)
        .where((user) => user.uid != currentUser.uid)
        .toList();

    users.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return users;
  }

  Future<List<ChatUser>> searchUsers(String query) async {
    final allUsers = await getUsers();
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      return allUsers;
    }

    return allUsers.where((user) {
      final nameMatch = user.name.toLowerCase().contains(searchText);
      final emailMatch = user.email.toLowerCase().contains(searchText);
      return nameMatch || emailMatch;
    }).toList();
  }

  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No logged-in user found.');
    }

    if (receiverId == currentUser.uid) {
      throw Exception('You cannot start a chat with yourself.');
    }

    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return;
    }

    final chatId = buildChatId(currentUser.uid, receiverId);
    final now = DateTime.now();
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: messageRef.id,
      chatId: chatId,
      senderId: currentUser.uid,
      receiverId: receiverId,
      text: cleanText,
      createdAt: now,
      status: 'sent',
      isFromCurrentUser: true,
    );

    await _firestore.collection('chats').doc(chatId).set({
      'chatId': chatId,
      'participants': [currentUser.uid, receiverId],
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': cleanText,
      'lastMessageSenderId': currentUser.uid,
      'lastMessageAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));

    await messageRef.set(message.toMap());
  }

  Stream<List<ChatMessage>> watchMessages(String otherUserId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    final chatId = buildChatId(currentUser.uid, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs
              .map(
                (doc) => ChatMessage.fromDocument(
                  doc,
                  currentUserId: currentUser.uid,
                ),
              )
              .toList();

          Future.microtask(() => markMessagesAsSeen(otherUserId));
          return messages;
        });
  }

  Future<void> markMessagesAsSeen(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final chatId = buildChatId(currentUser.uid, otherUserId);
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('status', isNotEqualTo: 'seen')
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'status': 'seen'});
    }
  }
}
