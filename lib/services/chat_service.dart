import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chavez_advmobprog2627/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // get all users
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('chat_directory').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {...doc.data(), 'uid': doc.data()['uid'] ?? doc.id};
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(String receiverId, message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String? currentUserEmail = _firebaseAuth.currentUser!.email;
    final Timestamp timestamp = Timestamp.now();

    MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail ?? "",
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
      status: 'delivered',
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomId = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Future<void> markMessageSeen(
    String messageId,
    String userId,
    String otherUserId,
  ) async {
    final ids = [userId, otherUserId]..sort();
    final chatRoomId = ids.join('_');
    final message = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .get();
    final data = message.data();
    if (data != null &&
        data['receiverId'] == userId &&
        data['status'] != 'seen') {
      await message.reference.update({'status': 'seen'});
    }
  }

  // get message
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [userID, otherUserID];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String?> getUidByEmail(String email) async {
    final q = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    // Ensure your Users doc actually stores the Firebase Auth UID in a field `uid`
    return (q.docs.first.data()['uid'] ?? '').toString();
  }
}
