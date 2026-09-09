import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/user_session_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../models/app_user.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends GetView<ProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Get.find<UserSessionController>().currentUser.value;
    if (controller.editNameController.text.isEmpty && currentUser != null) {
      controller.editNameController.text = currentUser.name;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: _EditProfileForm(controller: controller, currentUser: currentUser),
        ),
      ),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final ProfileController controller;
  final AppUser? currentUser;

  const _EditProfileForm({required this.controller, required this.currentUser});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.controller.saveDisplayName();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: UserAvatar(
              name: widget.currentUser?.name ?? '',
              photoUrl: widget.currentUser?.photoUrl,
              radius: 44,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text('Display name', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: widget.controller.editNameController,
            label: 'Name',
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            validator: Validators.name,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Obx(() => PrimaryButton(
                label: 'Save Changes',
                isLoading: widget.controller.isSavingProfile.value,
                onPressed: _submit,
              )),
        ],
      ),
    );
  }
}
