import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: _RegisterForm(controller: controller),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final AuthController controller;

  const _RegisterForm({required this.controller});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.controller.register();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Create your account', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sign up to start calling your contacts.',
            style: AppTypography.body.copyWith(color: secondaryText),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppTextField(
            controller: controller.registerNameController,
            label: 'Name',
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            validator: Validators.name,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: controller.registerEmailController,
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(() => AppTextField(
                controller: controller.registerPasswordController,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: controller.isPasswordHidden.value,
                validator: Validators.registerPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              )),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: controller.registerConfirmPasswordController,
            label: 'Confirm password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: Validators.confirmPassword(() => controller.registerPasswordController.text),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.lg),
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
          Obx(() => PrimaryButton(
                label: 'Create Account',
                isLoading: controller.isLoading.value,
                onPressed: _submit,
              )),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?', style: AppTypography.body.copyWith(color: secondaryText)),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Sign in', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
