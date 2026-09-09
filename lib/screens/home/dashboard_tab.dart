import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/call_history_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/user_session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/call_history_tile.dart';
import '../../widgets/contact_tile.dart';
import '../../widgets/search_field.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/user_avatar.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<UserSessionController>();
    final contactsController = Get.find<ContactsController>();
    final historyController = Get.find<CallHistoryController>();
    final homeController = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final user = session.currentUser.value;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome back', style: AppTypography.caption.copyWith(color: secondaryText)),
                              const SizedBox(height: 2),
                              Text(
                                user?.name.isNotEmpty == true ? user!.name : 'there',
                                style: AppTypography.h2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => homeController.changeTab(3),
                          child: UserAvatar(name: user?.name ?? '', photoUrl: user?.photoUrl, radius: 22),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: AppSpacing.xl),
                  SearchField(onTap: () => homeController.changeTab(1), onChanged: contactsController.updateSearch),
                  const SizedBox(height: AppSpacing.xxxl),
                  _SectionHeader(title: 'Contacts', onSeeAll: () => homeController.changeTab(1)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                if (contactsController.isLoading.value) {
                  return const _InlineSkeleton(count: 3);
                }
                final contacts = contactsController.contacts.take(3).toList();
                if (contacts.isEmpty) {
                  return _InlineHint(text: 'No contacts yet.', color: secondaryText);
                }
                return Column(
                  children: contacts
                      .map((contact) => ContactTile(
                            user: contact,
                            onAudioCall: () => contactsController.callContact(contact, isVideoCall: false),
                            onVideoCall: () => contactsController.callContact(contact, isVideoCall: true),
                          ))
                      .toList(),
                );
              }),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(title: 'Recent Calls', onSeeAll: () => homeController.changeTab(2)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                if (historyController.isLoading.value) {
                  return const _InlineSkeleton(count: 3);
                }
                final recent = historyController.history.take(3).toList();
                if (recent.isEmpty) {
                  return _InlineHint(text: 'No recent calls.', color: secondaryText);
                }
                return Column(
                  children: recent.map((record) => CallHistoryTile(record: record)).toList(),
                );
              }),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.h3),
        TextButton(
          onPressed: onSeeAll,
          child: Text('See all', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _InlineHint extends StatelessWidget {
  final String text;
  final Color color;

  const _InlineHint({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Text(text, style: AppTypography.body.copyWith(color: color)),
    );
  }
}

class _InlineSkeleton extends StatelessWidget {
  final int count;

  const _InlineSkeleton({required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: count * 68,
      child: ShimmerSkeletonList(itemCount: count),
    );
  }
}
