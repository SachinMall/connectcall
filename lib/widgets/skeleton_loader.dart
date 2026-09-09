import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({super.key, required this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SkeletonBox(width: 48, height: 48, radius: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: MediaQuery.of(context).size.width * 0.4, height: 14),
                const SizedBox(height: 8),
                const SkeletonBox(width: 70, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerSkeletonList extends StatelessWidget {
  final int itemCount;

  const ShimmerSkeletonList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface : AppColors.lightBorder,
      highlightColor: isDark ? AppColors.darkBorder : AppColors.lightSurface,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const SkeletonListTile(),
      ),
    );
  }
}

class ShimmerProfileHeader extends StatelessWidget {
  const ShimmerProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface : AppColors.lightBorder,
      highlightColor: isDark ? AppColors.darkBorder : AppColors.lightSurface,
      child: Column(
        children: [
          const SkeletonBox(width: 96, height: 96, radius: 48),
          const SizedBox(height: 16),
          const SkeletonBox(width: 140, height: 16),
          const SizedBox(height: 8),
          const SkeletonBox(width: 180, height: 12),
        ],
      ),
    );
  }
}
