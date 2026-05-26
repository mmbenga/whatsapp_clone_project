import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';


class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = Uuid();


  Stream<List<Message>> messagesStream(String chatId) {
    return _db.collection('chats').doc(chatId).collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Message.fromMap(d.data())).toList());
  }


  Future<void> sendMessage({required String chatId, required String fromId, required String toId, String text = '', String? imageUrl}) async {
    final id = _uuid.v4();
    final msg = Message(id: id, fromId: fromId, toId: toId, text: text, imageUrl: imageUrl, timestamp: DateTime.now());
    await _db.collection('chats').doc(chatId).collection('messages').doc(id).set(msg.toMap());


// update last message
    await _db.collection('chats').doc(chatId).set({'lastMessage': text, 'lastSeen': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}