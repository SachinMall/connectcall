import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.xxxl * 2),
                child: const _LoginForm(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthController controller = Get.find<AuthController>();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await controller.login();
  }

  Future<void> _showForgotPasswordSheet() async {
    final emailController = TextEditingController(text: controller.loginEmailController.text.trim());
    final sheetFormKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final sheetSecondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        final sheetBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.xxxl),
            decoration: BoxDecoration(
              color: Theme.of(sheetContext).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: sheetFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: sheetBorder, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Reset your password', style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enter your email and we will send you a link to reset your password.',
                    style: AppTypography.body.copyWith(color: sheetSecondaryText),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Obx(() => PrimaryButton(
                        label: 'Send Reset Link',
                        isLoading: controller.isSendingResetLink.value,
                        onPressed: () async {
                          FocusScope.of(sheetContext).unfocus();
                          if (!(sheetFormKey.currentState?.validate() ?? false)) return;
                          final success = await controller.sendPasswordResetEmail(emailController.text);
                          if (success && sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                            Get.snackbar('Check your email', 'A password reset link has been sent.');
                          }
                        },
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('assets/images/applogo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Welcome back', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Log in to keep connecting with your contacts.',
            style: AppTypography.body.copyWith(color: secondaryText),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppTextField(
            controller: controller.loginEmailController,
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(() => AppTextField(
                controller: controller.loginPasswordController,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: controller.isPasswordHidden.value,
                validator: Validators.loginPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              )),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordSheet,
              child: Text('Forgot password?', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary)),
            ),
          ),
          Obx(() {
            final message = controller.errorMessage.value;
            if (message == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(message, style: AppTypography.bodySmall.copyWith(color: AppColors.error))),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          Obx(() => PrimaryButton(
                label: 'Sign In',
                isLoading: controller.isLoading.value,
                onPressed: _submit,
              )),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: AppTypography.body.copyWith(color: secondaryText)),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.register),
                child: Text('Create account', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
