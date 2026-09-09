import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/call_history_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/call_history_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';

class CallHistoryTab extends GetView<CallHistoryController> {
  const CallHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Calls', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ShimmerSkeletonList();
                }

                final error = controller.errorMessage.value;
                if (error != null) {
                  return EmptyState(icon: Icons.wifi_off_rounded, title: 'Something went wrong', message: error);
                }

                final history = controller.history;
                if (history.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'No calls yet',
                    message: 'Your call history will show up here once you start calling.',
                  );
                }

                return ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => CallHistoryTile(record: history[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
