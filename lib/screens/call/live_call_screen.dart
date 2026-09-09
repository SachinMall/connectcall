import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/app_user.dart';
import '../../models/call_invite.dart';
import '../../models/call_record.dart';
import '../../services/call_history_service.dart';
import '../../services/call_invite_service.dart';
import '../../services/zego_call_engine_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/user_avatar.dart';

enum _CallStage { connecting, connected, reconnecting, ended }

class LiveCallScreen extends StatefulWidget {
  final String callId;
  final CallMediaType mediaType;
  final CallDirection direction;
  final AppUser currentUser;
  final AppUser peer;

  const LiveCallScreen({
    super.key,
    required this.callId,
    required this.mediaType,
    required this.direction,
    required this.currentUser,
    required this.peer,
  });

  @override
  State<LiveCallScreen> createState() => _LiveCallScreenState();
}

class _LiveCallScreenState extends State<LiveCallScreen> {
  final CallHistoryService _callHistoryService = CallHistoryService();
  final CallInviteService _callInviteService = CallInviteService();
  final ZegoCallEngineService _engine = ZegoCallEngineService.instance;

  late final DateTime _startedAt;
  late final String _localStreamId;
  late final String _calleeIdForInvite;
  Timer? _durationTicker;
  Timer? _reconnectGraceTimer;
  StreamSubscription<CallInvite?>? _inviteSubscription;
  CallInviteStatus? _lastKnownInviteStatus;
  DateTime? _connectedAt;
  bool _hasReachedConnected = false;

  _CallStage _stage = _CallStage.connecting;
  Duration _elapsed = Duration.zero;
  Widget? _localPreviewView;
  Widget? _remotePreviewView;
  String? _remoteStreamId;
  bool _isMicrophoneMuted = false;
  bool _isCameraEnabled = true;
  bool _isSpeakerOn = true;
  NetworkQualityLevel _networkQuality = NetworkQualityLevel.unknown;

  bool get _isVideoCall => widget.mediaType == CallMediaType.video;

  bool get _hasInviteAcceptedOrLater {
    switch (_lastKnownInviteStatus) {
      case CallInviteStatus.accepted:
      case CallInviteStatus.connecting:
      case CallInviteStatus.connected:
        return true;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _localStreamId = _engine.buildStreamId(widget.callId, widget.currentUser.id);
    _calleeIdForInvite = widget.direction == CallDirection.outgoing ? widget.peer.id : widget.currentUser.id;
    _isCameraEnabled = _isVideoCall;

    if (AppConfig.isZegoConfigured) {
      _setupCallEngine();
    }

    if (widget.direction == CallDirection.outgoing) {
      _inviteSubscription = _callInviteService.watchOutgoing(widget.peer.id).listen((invite) {
        if (invite == null) return;
        final previousStatus = _lastKnownInviteStatus;
        _lastKnownInviteStatus = invite.status;

        if (invite.status == CallInviteStatus.declined && mounted) {
          Navigator.of(context).pop();
          return;
        }

        if (invite.status != previousStatus && mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> _setupCallEngine() async {
    _bindEngineCallbacks();

    if (widget.direction == CallDirection.incoming) {
      _writeInviteStatus(CallInviteStatus.connecting);
    }

    await _engine.joinRoom(
      roomId: widget.callId,
      userId: widget.currentUser.id,
      userName: widget.currentUser.name,
      isVideoCall: _isVideoCall,
    );

    _isSpeakerOn = _engine.isSpeakerOn;

    if (_isVideoCall) {
      final localView = await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _engine.startPreview(ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill));
      });
      if (mounted) setState(() => _localPreviewView = localView);
    }
  }

  void _bindEngineCallbacks() {
    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, streamList, extendedData) {
      if (roomID != widget.callId) return;

      if (updateType == ZegoUpdateType.Add) {
        final remoteStream = streamList.firstWhere(
          (item) => item.streamID != _localStreamId,
          orElse: () => streamList.first,
        );
        if (remoteStream.streamID != _localStreamId) {
          _playRemoteStream(remoteStream.streamID);
        }
      } else if (updateType == ZegoUpdateType.Delete) {
        if (streamList.any((item) => item.streamID == _remoteStreamId) &&
            _hasReachedConnected &&
            _stage != _CallStage.reconnecting) {
          _startReconnectGracePeriod();
        }
      }
    };

    ZegoExpressEngine.onRoomOnlineUserCountUpdate = (roomID, count) {
      if (roomID != widget.callId || !mounted) return;

      if (count >= 2) {
        if (!_hasReachedConnected) {
          _handleConnected();
        } else if (_stage == _CallStage.reconnecting) {
          _reconnectGraceTimer?.cancel();
          setState(() => _stage = _CallStage.connected);
        }
      } else if (count < 2 && _hasReachedConnected && _stage != _CallStage.reconnecting) {
        _startReconnectGracePeriod();
      }
    };

    ZegoExpressEngine.onPlayerQualityUpdate = (streamID, quality) {
      if (streamID != _remoteStreamId || !mounted) return;
      setState(() => _networkQuality = _engine.mapNetworkQuality(quality.level));
    };
  }

  void _handleConnected() {
    if (_hasReachedConnected || !mounted) return;
    _hasReachedConnected = true;
    _connectedAt = DateTime.now();
    setState(() => _stage = _CallStage.connected);
    _startDurationTicker();
    _writeInviteStatus(CallInviteStatus.connected);
  }

  Future<void> _playRemoteStream(String streamId) async {
    _remoteStreamId = streamId;

    if (_isVideoCall) {
      final remoteView = await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _engine.startPlayingRemoteStream(streamId, canvas: ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill));
      });
      if (mounted) setState(() => _remotePreviewView = remoteView);
    } else {
      await _engine.startPlayingRemoteStream(streamId);
    }
  }

  void _startReconnectGracePeriod() {
    setState(() => _stage = _CallStage.reconnecting);
    _reconnectGraceTimer?.cancel();
    _reconnectGraceTimer = Timer(const Duration(seconds: 8), _handlePeerLeft);
  }

  void _handlePeerLeft() {
    if (!mounted) return;
    _endCall();
  }

  void _startDurationTicker() {
    _durationTicker?.cancel();
    _durationTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _connectedAt == null) return;
      setState(() => _elapsed = DateTime.now().difference(_connectedAt!));
    });
  }

  void _writeInviteStatus(CallInviteStatus status) {
    _callInviteService.updateStatus(_calleeIdForInvite, status).catchError((_) {});
  }

  void _endCall() {
    if (_stage == _CallStage.ended) return;
    setState(() => _stage = _CallStage.ended);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _durationTicker?.cancel();
    _reconnectGraceTimer?.cancel();
    _inviteSubscription?.cancel();
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomOnlineUserCountUpdate = null;
    ZegoExpressEngine.onPlayerQualityUpdate = null;

    if (AppConfig.isZegoConfigured) {
      _engine.leaveRoom(widget.callId);
    }

    _recordCallHistory();
    super.dispose();
  }

  void _recordCallHistory() {
    final outcome = _resolveOutcome();
    final duration = outcome == CallOutcome.completed && _connectedAt != null
        ? DateTime.now().difference(_connectedAt!)
        : Duration.zero;

    _callHistoryService.addRecord(
      widget.currentUser.id,
      CallRecord(
        id: '',
        peerId: widget.peer.id,
        peerName: widget.peer.name,
        peerPhotoUrl: widget.peer.photoUrl,
        mediaType: widget.mediaType,
        direction: widget.direction,
        outcome: outcome,
        startedAt: _startedAt,
        duration: duration,
      ),
    );

    if (widget.direction == CallDirection.outgoing) {
      _callInviteService.clearInvite(widget.peer.id);
    }
  }

  CallOutcome _resolveOutcome() {
    if (_hasReachedConnected) return CallOutcome.completed;

    if (widget.direction == CallDirection.incoming) {
      return CallOutcome.failed;
    }

    final status = _lastKnownInviteStatus;
    if (status == CallInviteStatus.declined) return CallOutcome.rejected;
    return CallOutcome.missed;
  }

  Future<void> _onToggleMicrophone() async {
    await _engine.toggleMicrophone();
    setState(() => _isMicrophoneMuted = _engine.isMicrophoneMuted);
  }

  Future<void> _onToggleCamera() async {
    await _engine.toggleCamera();
    setState(() => _isCameraEnabled = _engine.isCameraEnabled);
  }

  Future<void> _onSwitchCamera() async {
    await _engine.switchCamera();
  }

  Future<void> _onToggleSpeaker() async {
    await _engine.toggleSpeaker();
    setState(() => _isSpeakerOn = _engine.isSpeakerOn);
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isZegoConfigured) {
      return const _CallingNotConfiguredView();
    }

    return Scaffold(
      backgroundColor: AppColors.callScreenBackground,
      body: SafeArea(
        child: _isVideoCall ? _buildVideoLayout() : _buildAudioLayout(),
      ),
    );
  }

  Widget _buildAudioLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.2,
          colors: [Color(0xFF13182B), AppColors.callScreenBackground],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          children: [
            const Spacer(flex: 2),
            StatusBadge(label: _networkQualityLabel, color: _networkQualityColor),
            const SizedBox(height: AppSpacing.xxl),
            _PulsingAvatar(
              name: widget.peer.name,
              photoUrl: widget.peer.photoUrl,
              isPulsing: _stage == _CallStage.connecting,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(widget.peer.name, style: AppTypography.h1.copyWith(color: Colors.white)),
            const SizedBox(height: AppSpacing.sm),
            Text(_statusLabel, style: AppTypography.bodyLarge.copyWith(color: Colors.white60)),
            const Spacer(flex: 3),
            _buildControlsRow(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayout() {
    return Stack(
      children: [
        Positioned.fill(
          child: _remotePreviewView ??
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3),
                    radius: 1.2,
                    colors: [Color(0xFF13182B), AppColors.callScreenBackground],
                  ),
                ),
                child: Center(
                  child: UserAvatar(name: widget.peer.name, photoUrl: widget.peer.photoUrl, radius: 60),
                ),
              ),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(label: _networkQualityLabel, color: _networkQualityColor),
              _PeerLabel(name: widget.peer.name, statusLabel: _statusLabel),
            ],
          ),
        ),
        if (_isCameraEnabled)
          Positioned(
            top: 76,
            right: 16,
            child: Container(
              width: 108,
              height: 148,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: _localPreviewView ?? Container(color: Colors.black45),
            ),
          )
        else
          Positioned(
            top: 76,
            right: 16,
            child: Container(
              width: 108,
              height: 148,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 22),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: _buildControlsRow(),
        ),
      ],
    );
  }

  String get _networkQualityLabel {
    switch (_networkQuality) {
      case NetworkQualityLevel.good:
        return 'Good connection';
      case NetworkQualityLevel.fair:
        return 'Fair connection';
      case NetworkQualityLevel.poor:
        return 'Poor connection';
      case NetworkQualityLevel.unknown:
        return 'Connecting';
    }
  }

  Color get _networkQualityColor {
    switch (_networkQuality) {
      case NetworkQualityLevel.good:
        return AppColors.success;
      case NetworkQualityLevel.fair:
        return AppColors.warning;
      case NetworkQualityLevel.poor:
        return AppColors.error;
      case NetworkQualityLevel.unknown:
        return Colors.white38;
    }
  }

  String get _statusLabel {
    if (_stage == _CallStage.reconnecting) return 'Reconnecting...';
    if (_stage == _CallStage.connected) return _formatDuration(_elapsed);
    if (widget.direction == CallDirection.outgoing) {
      return _hasInviteAcceptedOrLater ? 'Connecting...' : 'Ringing...';
    }
    return 'Connecting...';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildControlsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CallControlButton(
          icon: _isMicrophoneMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          label: _isMicrophoneMuted ? 'Unmute' : 'Mute',
          isActive: _isMicrophoneMuted,
          onTap: _onToggleMicrophone,
        ),
        if (_isVideoCall)
          _CallControlButton(
            icon: _isCameraEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
            label: 'Camera',
            isActive: !_isCameraEnabled,
            onTap: _onToggleCamera,
          )
        else
          _CallControlButton(
            icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.hearing_rounded,
            label: 'Speaker',
            isActive: _isSpeakerOn,
            onTap: _onToggleSpeaker,
          ),
        if (_isVideoCall)
          _CallControlButton(
            icon: Icons.cameraswitch_rounded,
            label: 'Switch',
            isActive: false,
            onTap: _onSwitchCamera,
          ),
        _CallControlButton(
          icon: Icons.call_end_rounded,
          label: 'End',
          isActive: false,
          isDestructive: true,
          onTap: _endCall,
        ),
      ],
    );
  }
}

class _PulsingAvatar extends StatefulWidget {
  final String name;
  final String? photoUrl;
  final bool isPulsing;

  const _PulsingAvatar({required this.name, required this.photoUrl, required this.isPulsing});

  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
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
        final scale = widget.isPulsing ? 1 + (_controller.value * 0.08) : 1.0;
        final opacity = widget.isPulsing ? 0.25 - (_controller.value * 0.15) : 0.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale + 0.18,
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
      child: UserAvatar(name: widget.name, photoUrl: widget.photoUrl, radius: 60),
    );
  }
}

class _PeerLabel extends StatelessWidget {
  final String name;
  final String statusLabel;

  const _PeerLabel({required this.name, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(name, style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
          Text(statusLabel, style: AppTypography.caption.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDestructive;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = isDestructive ? AppColors.error : (isActive ? Colors.white : Colors.white.withValues(alpha: 0.14));
    final iconColor = isDestructive ? Colors.white : (isActive ? Colors.black87 : Colors.white);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: resolvedColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(isDestructive ? 18 : 16),
              child: Icon(icon, color: iconColor, size: isDestructive ? 28 : 24),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white70)),
      ],
    );
  }
}

class _CallingNotConfiguredView extends StatelessWidget {
  const _CallingNotConfiguredView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.callScreenBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: const Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 26),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Calling is not configured yet',
                style: AppTypography.h3.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Add your ZEGOCLOUD AppID and AppSign in app_config.dart.',
                style: AppTypography.body.copyWith(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
