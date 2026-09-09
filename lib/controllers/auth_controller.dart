import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isSendingResetLink = false.obs;
  final errorMessage = RxnString();

  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;

  Future<bool> sendPasswordResetEmail(String email) async {
    isSendingResetLink.value = true;
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (error) {
      Get.snackbar('Could not send reset link', _readableAuthError(error));
      return false;
    } catch (_) {
      Get.snackbar('Could not send reset link', 'Check your connection and try again.');
      return false;
    } finally {
      isSendingResetLink.value = false;
    }
  }

  Future<void> login() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Enter your email and password to continue.';
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      await _authService.signIn(email: email, password: password);
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (error) {
      errorMessage.value = _readableAuthError(error);
    } catch (_) {
      errorMessage.value = 'Something went wrong. Check your connection and try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final name = registerNameController.text.trim();
    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text;
    final confirmPassword = registerConfirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Fill in all fields to create your account.';
      return;
    }
    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match.';
      return;
    }
    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters.';
      return;
    }

    errorMessage.value = null;
    isLoading.value = true;
    try {
      await _authService.register(name: name, email: email, password: password);
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (error) {
      errorMessage.value = _readableAuthError(error);
    } catch (_) {
      errorMessage.value = 'Something went wrong. Check your connection and try again.';
    } finally {
      isLoading.value = false;
    }
  }

  String _readableAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'No internet connection. Try again.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.onClose();
  }
}
