import 'dart:async';

import 'package:get/get.dart';
import '../models/call_invite.dart';
import '../screens/call/incoming_call_screen.dart';
import '../services/call_invite_service.dart';

class IncomingCallController extends GetxController {
  final String currentUserId;
  final CallInviteService _callInviteService = CallInviteService();

  StreamSubscription<CallInvite?>? _subscription;
  bool _isShowingIncomingScreen = false;

  IncomingCallController(this.currentUserId);

  @override
  void onInit() {
    super.onInit();
    _subscription = _callInviteService.watchIncoming(currentUserId).listen(_handleInvite);
  }

  void _handleInvite(CallInvite? invite) {
    if (invite == null) return;
    if (invite.status != CallInviteStatus.ringing) return;
    if (invite.isStale) return;
    if (_isShowingIncomingScreen) return;

    _isShowingIncomingScreen = true;
    Get.to(() => IncomingCallScreen(invite: invite, currentUserId: currentUserId))
        ?.whenComplete(() => _isShowingIncomingScreen = false);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
