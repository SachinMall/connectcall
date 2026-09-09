import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/call_record.dart';
import '../services/call_permission_service.dart';

Future<bool> ensureCallPermission(CallMediaType mediaType) async {
  final permissionService = CallPermissionService();
  final result = mediaType == CallMediaType.video
      ? await permissionService.ensureVideoPermission()
      : await permissionService.ensureAudioPermission();

  switch (result) {
    case CallPermissionResult.granted:
      return true;
    case CallPermissionResult.denied:
      Get.snackbar(
        'Permission required',
        mediaType == CallMediaType.video
            ? 'Camera and microphone access is needed to make a video call.'
            : 'Microphone access is needed to make a call.',
      );
      return false;
    case CallPermissionResult.permanentlyDenied:
      await Get.dialog(
        AlertDialog(
          title: const Text('Permission needed'),
          content: Text(
            mediaType == CallMediaType.video
                ? 'Camera and microphone access was permanently denied. Enable it in system settings to make video calls.'
                : 'Microphone access was permanently denied. Enable it in system settings to make calls.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
  }
}
