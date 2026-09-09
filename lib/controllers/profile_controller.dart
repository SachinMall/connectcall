import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/push_token_service.dart';
import '../services/user_directory_service.dart';
import 'user_session_controller.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  final UserDirectoryService _userDirectoryService = UserDirectoryService();
  final GetStorage _storage = GetStorage();

  final isDarkMode = false.obs;
  final isSigningOut = false.obs;

  final editNameController = TextEditingController();
  final isSavingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read('isDarkMode') ?? false;
  }

  void toggleDarkMode(bool enabled) {
    isDarkMode.value = enabled;
    _storage.write('isDarkMode', enabled);
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> saveDisplayName() async {
    final newName = editNameController.text.trim();
    if (newName.isEmpty) return;

    final session = Get.find<UserSessionController>();
    isSavingProfile.value = true;
    try {
      await _userDirectoryService.updateProfile(session.userId, name: newName);
      await session.refreshProfile();
      Get.back();
    } finally {
      isSavingProfile.value = false;
    }
  }

  Future<void> signOut() async {
    isSigningOut.value = true;
    try {
      final session = Get.find<UserSessionController>();
      await PushTokenService.instance.clearTokenForUser(session.userId);
      await _authService.signOut();
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isSigningOut.value = false;
    }
  }

  @override
  void onClose() {
    editNameController.dispose();
    super.onClose();
  }
}
