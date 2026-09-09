import 'package:get/get.dart';
import '../core/config/app_config.dart';
import '../models/app_user.dart';
import '../models/call_record.dart';
import '../screens/call/live_call_screen.dart';
import '../widgets/call_permission_dialog.dart';
import 'call_invite_service.dart';

class CallNavigator {
  CallNavigator._();

  static final CallInviteService _callInviteService = CallInviteService();
  static bool _isPlacingCall = false;

  static String buildCallId(String userIdA, String userIdB) {
    final ids = [userIdA, userIdB]..sort();
    return 'call_${ids.first}_${ids.last}';
  }

  static Future<void> placeCall({
    required AppUser caller,
    required AppUser callee,
    required CallMediaType mediaType,
  }) async {
    if (_isPlacingCall) return;

    if (!AppConfig.isZegoConfigured) {
      Get.snackbar('Calling not configured', 'Add your ZEGOCLOUD AppID and AppSign in app_config.dart.');
      return;
    }

    _isPlacingCall = true;
    try {
      final hasPermission = await ensureCallPermission(mediaType);
      if (!hasPermission) return;

      final callId = buildCallId(caller.id, callee.id);

      await _callInviteService.sendInvite(
        calleeId: callee.id,
        callId: callId,
        callerId: caller.id,
        callerName: caller.name,
        callerPhotoUrl: caller.photoUrl,
        mediaType: mediaType,
      );

      await Get.to(() => LiveCallScreen(
            callId: callId,
            mediaType: mediaType,
            direction: CallDirection.outgoing,
            currentUser: caller,
            peer: callee,
          ));
    } finally {
      _isPlacingCall = false;
    }
  }

  static void replaceWithAcceptedCall({
    required AppUser me,
    required AppUser caller,
    required CallMediaType mediaType,
  }) {
    Get.off(() => LiveCallScreen(
          callId: buildCallId(me.id, caller.id),
          mediaType: mediaType,
          direction: CallDirection.incoming,
          currentUser: me,
          peer: caller,
        ));
  }
}
