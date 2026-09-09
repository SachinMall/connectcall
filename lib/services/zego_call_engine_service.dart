import 'package:zego_express_engine/zego_express_engine.dart';
import '../core/config/app_config.dart';

enum NetworkQualityLevel { good, fair, poor, unknown }

class ZegoCallEngineService {
  static ZegoCallEngineService? _instance;
  static ZegoCallEngineService get instance => _instance ??= ZegoCallEngineService._();

  ZegoCallEngineService._();

  bool _isEngineCreated = false;
  bool _isMicrophoneMuted = false;
  bool _isCameraEnabled = true;
  bool _isFrontCamera = true;
  bool _isSpeakerOn = true;

  bool get isMicrophoneMuted => _isMicrophoneMuted;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isFrontCamera => _isFrontCamera;
  bool get isSpeakerOn => _isSpeakerOn;

  Future<void> ensureEngineCreated() async {
    if (_isEngineCreated) return;
    await ZegoExpressEngine.createEngineWithProfile(
      ZegoEngineProfile(
        AppConfig.zegoAppId,
        ZegoScenario.StandardVideoCall,
        appSign: AppConfig.zegoAppSign,
      ),
    );
    _isEngineCreated = true;
  }

  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required String userName,
    required bool isVideoCall,
  }) async {
    await ensureEngineCreated();
    _isCameraEnabled = isVideoCall;
    _isFrontCamera = true;
    _isMicrophoneMuted = false;
    _isSpeakerOn = isVideoCall;

    await ZegoExpressEngine.instance.loginRoom(
      roomId,
      ZegoUser(userId, userName),
      config: ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true,
    );

    await ZegoExpressEngine.instance.enableCamera(isVideoCall);
    await ZegoExpressEngine.instance.muteMicrophone(false);
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(isVideoCall);

    await ZegoExpressEngine.instance.startPublishingStream(buildStreamId(roomId, userId));
  }

  String buildStreamId(String roomId, String userId) => '${roomId}_$userId';

  Future<void> startPreview(ZegoCanvas canvas) {
    return ZegoExpressEngine.instance.startPreview(canvas: canvas);
  }

  Future<void> startPlayingRemoteStream(String streamId, {ZegoCanvas? canvas}) {
    return ZegoExpressEngine.instance.startPlayingStream(streamId, canvas: canvas);
  }

  Future<void> stopPlayingRemoteStream(String streamId) {
    return ZegoExpressEngine.instance.stopPlayingStream(streamId);
  }

  Future<void> toggleMicrophone() async {
    _isMicrophoneMuted = !_isMicrophoneMuted;
    await ZegoExpressEngine.instance.muteMicrophone(_isMicrophoneMuted);
  }

  Future<void> toggleCamera() async {
    _isCameraEnabled = !_isCameraEnabled;
    await ZegoExpressEngine.instance.enableCamera(_isCameraEnabled);
  }

  Future<void> switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await ZegoExpressEngine.instance.useFrontCamera(_isFrontCamera);
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(_isSpeakerOn);
  }

  Future<void> leaveRoom(String roomId) async {
    await ZegoExpressEngine.instance.stopPublishingStream();
    await ZegoExpressEngine.instance.stopPreview();
    await ZegoExpressEngine.instance.logoutRoom(roomId);
  }

  NetworkQualityLevel mapNetworkQuality(ZegoStreamQualityLevel level) {
    switch (level) {
      case ZegoStreamQualityLevel.Excellent:
      case ZegoStreamQualityLevel.Good:
        return NetworkQualityLevel.good;
      case ZegoStreamQualityLevel.Medium:
        return NetworkQualityLevel.fair;
      case ZegoStreamQualityLevel.Bad:
      case ZegoStreamQualityLevel.Die:
        return NetworkQualityLevel.poor;
      default:
        return NetworkQualityLevel.unknown;
    }
  }
}
