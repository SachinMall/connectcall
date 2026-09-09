import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/app_user.dart';
import '../services/push_token_service.dart';
import '../services/user_directory_service.dart';

class UserSessionController extends GetxController {
  final UserDirectoryService _userDirectoryService = UserDirectoryService();

  final Rxn<AppUser> currentUser = Rxn<AppUser>();

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    PushTokenService.instance.registerTokenForUser(userId);
  }

  Future<void> _loadProfile() async {
    if (userId.isEmpty) return;
    final profile = await _userDirectoryService.fetchUser(userId);
    currentUser.value = profile;
  }

  Future<void> refreshProfile() => _loadProfile();
}
