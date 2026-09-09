import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class RingtoneService {
  RingtoneService._();
  static final RingtoneService instance = RingtoneService._();

  final FlutterRingtonePlayer _player = FlutterRingtonePlayer();
  bool _isRinging = false;

  Future<void> startIncomingCallRingtone() async {
    if (_isRinging) return;
    _isRinging = true;
    try {
      await _player.playRingtone(looping: true, volume: 1, asAlarm: false);
    } catch (_) {
      _isRinging = false;
    }
  }

  Future<void> stop() async {
    if (!_isRinging) return;
    _isRinging = false;
    try {
      await _player.stop();
    } catch (_) {}
  }
}
