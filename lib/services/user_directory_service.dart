import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserDirectoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppUser>> watchContacts(String excludeUserId) {
    return _firestore
        .collection('users')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.id != excludeUserId)
            .map((doc) => AppUser.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<AppUser?> fetchUser(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    if (!snapshot.exists) return null;
    return AppUser.fromMap(userId, snapshot.data()!);
  }

  Future<void> updateProfile(String userId, {String? name, String? photoUrl}) {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    return _firestore.collection('users').doc(userId).update(updates);
  }
}
