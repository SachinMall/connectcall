import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_record.dart';

class CallHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _historyRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('callHistory');
  }

  Stream<List<CallRecord>> watchHistory(String userId) {
    return _historyRef(userId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CallRecord.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addRecord(String userId, CallRecord record) {
    return _historyRef(userId).add(record.toMap());
  }
}
