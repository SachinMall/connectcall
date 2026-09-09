import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../controllers/user_session_controller.dart';
import '../../models/app_user.dart';
import '../../models/call_invite.dart';
import '../../models/call_record.dart';
import '../../services/call_history_service.dart';
import '../../services/call_invite_service.dart';
import '../../services/call_navigator.dart';
import '../../services/local_notification_service.dart';
import '../../services/ringtone_service.dart';
import '../../widgets/call_permission_dialog.dart';
import '../../widgets/user_avatar.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallInvite invite;
  final String currentUserId;

  const IncomingCallScreen({
    super.key,
    required this.invite,
    required this.currentUserId,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallInviteService _callInviteService = CallInviteService();
  final CallHistoryService _callHistoryService = CallHistoryService();

  StreamSubscription<CallInvite?>? _subscription;
  Timer? _ringTimeoutTimer;
  bool _hasResolved = false;

  @override
  void initState() {
    super.initState();
    _subscription = _callInviteService.watchIncoming(widget.currentUserId).listen(_onInviteChanged);
    _ringTimeoutTimer = Timer(const Duration(seconds: 30), _handleMissed);
    RingtoneService.instance.startIncomingCallRingtone();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _ringTimeoutTimer?.cancel();
    RingtoneService.instance.stop();
    LocalNotificationService.instance.dismissIncomingCall();
    super.dispose();
  }

  void _onInviteChanged(CallInvite? invite) {
    if (_hasResolved) return;
    if (invite == null || invite.status == CallInviteStatus.cancelled) {
      _finish();
    }
  }

  void _finish() {
    if (_hasResolved) return;
    _hasResolved = true;
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }

  Future<void> _handleAccept() async {
    if (_hasResolved) return;

    final hasPermission = await ensureCallPermission(widget.invite.mediaType);
    if (!hasPermission || _hasResolved) return;

    _hasResolved = true;
    _ringTimeoutTimer?.cancel();

    await _callInviteService.updateStatus(widget.currentUserId, CallInviteStatus.accepted);

    final caller = AppUser(
      id: widget.invite.callerId,
      name: widget.invite.callerName,
      email: '',
      photoUrl: widget.invite.callerPhotoUrl,
    );
    final me = Get.find<UserSessionController>().currentUser.value ??
        AppUser(id: widget.currentUserId, name: 'You', email: '');

    CallNavigator.replaceWithAcceptedCall(me: me, caller: caller, mediaType: widget.invite.mediaType);
  }

  Future<void> _handleDecline() async {
    if (_hasResolved) return;
    _hasResolved = true;
    _ringTimeoutTimer?.cancel();

    await _logHistory(CallOutcome.rejected);
    await _callInviteService.updateStatus(widget.currentUserId, CallInviteStatus.declined);
    Get.back();
  }

  Future<void> _handleMissed() async {
    if (_hasResolved) return;
    _hasResolved = true;

    await _logHistory(CallOutcome.missed);
    await _callInviteService.updateStatus(widget.currentUserId, CallInviteStatus.missed);
    _finish();
  }

  Future<void> _logHistory(CallOutcome outcome) {
    return _callHistoryService.addRecord(
      widget.currentUserId,
      CallRecord(
        id: '',
        peerId: widget.invite.callerId,
        peerName: widget.invite.callerName,
        peerPhotoUrl: widget.invite.callerPhotoUrl,
        mediaType: widget.invite.mediaType,
        direction: CallDirection.incoming,
        outcome: outcome,
        startedAt: widget.invite.createdAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVideoCall = widget.invite.mediaType == CallMediaType.video;

    return Scaffold(
      backgroundColor: AppColors.callScreenBackground,
      body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.3,
              colors: [Color(0xFF161C33), AppColors.callScreenBackground],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isVideoCall ? Icons.videocam_rounded : Icons.call_rounded, size: 15, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          isVideoCall ? 'Incoming video call' : 'Incoming audio call',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _IncomingPulsingAvatar(name: widget.invite.callerName, photoUrl: widget.invite.callerPhotoUrl),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    widget.invite.callerName,
                    style: AppTypography.h1.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(flex: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallActionButton(
                        icon: Icons.call_end_rounded,
                        backgroundColor: AppColors.error,
                        label: 'Decline',
                        onTap: _handleDecline,
                      ),
                      _CallActionButton(
                        icon: isVideoCall ? Icons.videocam_rounded : Icons.call_rounded,
                        backgroundColor: AppColors.success,
                        label: 'Accept',
                        onTap: _handleAccept,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
    );
  }
}



class _IncomingPulsingAvatar extends StatefulWidget {
  final String name;
  final String? photoUrl;

  const _IncomingPulsingAvatar({required this.name, required this.photoUrl});

  @override
  State<_IncomingPulsingAvatar> createState() => _IncomingPulsingAvatarState();
}

class _IncomingPulsingAvatarState extends State<_IncomingPulsingAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + (_controller.value * 0.1);
        final opacity = 0.3 - (_controller.value * 0.2);
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale + 0.2,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: opacity), width: 2),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: UserAvatar(name: widget.name, photoUrl: widget.photoUrl, radius: 56),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final String label;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white70)),
      ],
    );
  }
}
