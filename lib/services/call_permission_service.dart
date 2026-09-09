import 'package:permission_handler/permission_handler.dart';

enum CallPermissionResult { granted, denied, permanentlyDenied }

class CallPermissionService {
  Future<CallPermissionResult> ensureAudioPermission() async {
    return _request([Permission.microphone]);
  }

  Future<CallPermissionResult> ensureVideoPermission() async {
    return _request([Permission.microphone, Permission.camera]);
  }

  Future<CallPermissionResult> _request(List<Permission> permissions) async {
    final statuses = await permissions.request();

    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      return CallPermissionResult.permanentlyDenied;
    }
    if (statuses.values.every((status) => status.isGranted)) {
      return CallPermissionResult.granted;
    }
    return CallPermissionResult.denied;
  }
}
