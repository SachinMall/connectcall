import 'package:cloud_firestore/cloud_firestore.dart';
import 'call_record.dart';

enum CallInviteStatus { ringing, accepted, connecting, connected, declined, cancelled, missed, busy, ended, failed }

class CallInvite {
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerPhotoUrl;
  final CallMediaType mediaType;
  final CallInviteStatus status;
  final DateTime createdAt;

  const CallInvite({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerPhotoUrl,
    required this.mediaType,
    required this.status,
    required this.createdAt,
  });

  factory CallInvite.fromMap(Map<String, dynamic> map) {
    final createdAtTimestamp = map['createdAt'];
    return CallInvite(
      callId: map['callId'] as String? ?? '',
      callerId: map['callerId'] as String? ?? '',
      callerName: map['callerName'] as String? ?? '',
      callerPhotoUrl: map['callerPhotoUrl'] as String?,
      mediaType: CallMediaType.values.firstWhere(
        (type) => type.name == map['mediaType'],
        orElse: () => CallMediaType.audio,
      ),
      status: CallInviteStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => CallInviteStatus.ringing,
      ),
      createdAt: createdAtTimestamp is Timestamp ? createdAtTimestamp.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'callerPhotoUrl': callerPhotoUrl,
      'mediaType': mediaType.name,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isStale => DateTime.now().difference(createdAt) > const Duration(seconds: 45);
}
