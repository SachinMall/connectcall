import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    var isLoggedIn = false;
    try {
      isLoggedIn = FirebaseAuth.instance.currentUser != null;
    } catch (_) {}

    Get.offAllNamed(isLoggedIn ? AppRoutes.home : AppRoutes.login);
  }
}
