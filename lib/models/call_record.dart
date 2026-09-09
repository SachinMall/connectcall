import 'package:cloud_firestore/cloud_firestore.dart';

enum CallMediaType { audio, video }

enum CallDirection { incoming, outgoing }

enum CallOutcome { completed, missed, rejected, failed }

class CallRecord {
  final String id;
  final String peerId;
  final String peerName;
  final String? peerPhotoUrl;
  final CallMediaType mediaType;
  final CallDirection direction;
  final CallOutcome outcome;
  final DateTime startedAt;
  final Duration duration;

  const CallRecord({
    required this.id,
    required this.peerId,
    required this.peerName,
    this.peerPhotoUrl,
    required this.mediaType,
    required this.direction,
    required this.outcome,
    required this.startedAt,
    this.duration = Duration.zero,
  });

  factory CallRecord.fromMap(String id, Map<String, dynamic> map) {
    final startedAtTimestamp = map['startedAt'];
    return CallRecord(
      id: id,
      peerId: map['peerId'] as String? ?? '',
      peerName: map['peerName'] as String? ?? '',
      peerPhotoUrl: map['peerPhotoUrl'] as String?,
      mediaType: CallMediaType.values.firstWhere(
        (type) => type.name == map['mediaType'],
        orElse: () => CallMediaType.audio,
      ),
      direction: CallDirection.values.firstWhere(
        (dir) => dir.name == map['direction'],
        orElse: () => CallDirection.outgoing,
      ),
      outcome: CallOutcome.values.firstWhere(
        (out) => out.name == map['outcome'],
        orElse: () => CallOutcome.completed,
      ),
      startedAt: startedAtTimestamp is Timestamp ? startedAtTimestamp.toDate() : DateTime.now(),
      duration: Duration(seconds: map['durationSeconds'] as int? ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'peerId': peerId,
      'peerName': peerName,
      'peerPhotoUrl': peerPhotoUrl,
      'mediaType': mediaType.name,
      'direction': direction.name,
      'outcome': outcome.name,
      'startedAt': Timestamp.fromDate(startedAt),
      'durationSeconds': duration.inSeconds,
    };
  }
}
