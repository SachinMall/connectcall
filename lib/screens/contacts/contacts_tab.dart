import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/contacts_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/contact_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/search_field.dart';
import '../../widgets/skeleton_loader.dart';

class ContactsTab extends GetView<ContactsController> {
  const ContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Contacts', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.lg),
            SearchField(onChanged: controller.updateSearch),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ShimmerSkeletonList();
                }

                final error = controller.errorMessage.value;
                if (error != null) {
                  return EmptyState(icon: Icons.wifi_off_rounded, title: 'Something went wrong', message: error);
                }

                final contacts = controller.filteredContacts;
                if (contacts.isEmpty) {
                  final isSearching = controller.searchQuery.value.trim().isNotEmpty;
                  return EmptyState(
                    icon: isSearching ? Icons.search_off_rounded : Icons.people_outline_rounded,
                    title: isSearching ? 'No people found' : 'No contacts yet',
                    message: isSearching
                        ? 'Try searching with a different name or email.'
                        : 'Contacts will appear here once other people join ConnectCall.',
                  );
                }

                return ListView.separated(
                  itemCount: contacts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ContactTile(
                      user: contact,
                      onAudioCall: () => controller.callContact(contact, isVideoCall: false),
                      onVideoCall: () => controller.callContact(contact, isVideoCall: true),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
