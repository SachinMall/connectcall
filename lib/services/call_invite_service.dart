import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_invite.dart';
import '../models/call_record.dart';

class CallInviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _inviteRef(String calleeId) {
    return _firestore.collection('callInvites').doc(calleeId);
  }

  Future<void> sendInvite({
    required String calleeId,
    required String callId,
    required String callerId,
    required String callerName,
    String? callerPhotoUrl,
    required CallMediaType mediaType,
  }) {
    final invite = CallInvite(
      callId: callId,
      callerId: callerId,
      callerName: callerName,
      callerPhotoUrl: callerPhotoUrl,
      mediaType: mediaType,
      status: CallInviteStatus.ringing,
      createdAt: DateTime.now(),
    );
    return _inviteRef(calleeId).set(invite.toMap());
  }

  Stream<CallInvite?> watchIncoming(String userId) {
    return _inviteRef(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return CallInvite.fromMap(snapshot.data()!);
    });
  }

  Stream<CallInvite?> watchOutgoing(String calleeId) => watchIncoming(calleeId);

  Future<void> updateStatus(String calleeId, CallInviteStatus status) {
    return _inviteRef(calleeId).set({'status': status.name}, SetOptions(merge: true));
  }

  Future<void> clearInvite(String calleeId) {
    return _inviteRef(calleeId).delete();
  }
}
