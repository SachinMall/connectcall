import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/user_session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileTab extends GetView<ProfileController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<UserSessionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Obx(() {
          final user = session.currentUser.value;
          if (user == null) {
            return const Padding(padding: EdgeInsets.only(top: AppSpacing.huge), child: ShimmerProfileHeader());
          }

          return ListView(
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text('Profile', style: AppTypography.h1),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: UserAvatar(name: user.name, photoUrl: user.photoUrl, radius: 48),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(user.name, style: AppTypography.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user.email,
                  style: AppTypography.body.copyWith(color: secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.online.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Online', style: AppTypography.caption.copyWith(color: AppColors.online)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _SectionLabel(text: 'Account', color: secondaryText),
              _ProfileTile(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: () => Get.to(() => const EditProfileScreen()),
              ),
              Obx(() => _ToggleTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    value: controller.isDarkMode.value,
                    onChanged: controller.toggleDarkMode,
                  )),
              const SizedBox(height: AppSpacing.xxl),
              _SectionLabel(text: 'Session', color: secondaryText),
              Obx(() => _ProfileTile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    isDestructive: true,
                    isLoading: controller.isSigningOut.value,
                    onTap: controller.signOut,
                  )),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text.toUpperCase(), style: AppTypography.caption.copyWith(color: color, letterSpacing: 0.6)),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLoading;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: AppTypography.bodyMedium.copyWith(color: color)),
      trailing: isLoading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(Icons.chevron_right_rounded, size: 20, color: color),
      onTap: isLoading ? null : onTap,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      secondary: Icon(icon, size: 22),
      title: Text(label, style: AppTypography.bodyMedium),
      contentPadding: EdgeInsets.zero,
    );
  }
}
