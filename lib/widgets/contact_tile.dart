import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../models/app_user.dart';
import 'user_avatar.dart';

class ContactTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final VoidCallback? onTap;

  const ContactTile({
    super.key,
    required this.user,
    required this.onAudioCall,
    required this.onVideoCall,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              UserAvatar(name: user.name, photoUrl: user.photoUrl, showOnlineDot: true, isOnline: user.isOnline),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      user.isOnline ? 'Online' : 'Offline',
                      style: AppTypography.caption.copyWith(
                        color: user.isOnline ? AppColors.online : secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleIconButton(icon: Icons.call_outlined, onTap: onAudioCall),
              const SizedBox(width: AppSpacing.sm),
              _CircleIconButton(icon: Icons.videocam_outlined, onTap: onVideoCall),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 19, color: AppColors.primary),
        ),
      ),
    );
  }
}
