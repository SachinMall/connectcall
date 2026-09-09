import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final bool showOnlineDot;
  final bool isOnline;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 24,
    this.showOnlineDot = false,
    this.isOnline = false,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Color _backgroundFor(String seed) {
    const palette = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.cyan];
    final index = seed.isEmpty ? 0 : seed.codeUnitAt(0) % palette.length;
    return palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _backgroundFor(name);

    final avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor.withValues(alpha: 0.16), baseColor.withValues(alpha: 0.08)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => _InitialsLabel(initials: _initials, color: baseColor, radius: radius),
            )
          : _InitialsLabel(initials: _initials, color: baseColor, radius: radius),
    );

    if (!showOnlineDot) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: radius * 0.4,
            height: radius * 0.4,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.online : AppColors.offline,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialsLabel extends StatelessWidget {
  final String initials;
  final Color color;
  final double radius;

  const _InitialsLabel({required this.initials, required this.color, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: radius * 0.62),
      ),
    );
  }
}
