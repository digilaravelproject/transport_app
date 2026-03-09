import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get notification data from arguments
    final Map<String, dynamic> notification = Get.arguments ?? {
      'title': 'New Lead: Rajesh Kumar',
      'desc': 'Inquiry for Delhi-Shimla trip on 15th March.',
      'time': '2m ago',
      'icon': Iconsax.user,
      'color': AppColors.primaryColor,
      'fullMessage': 'Hello Partner,\n\nYou have received a new inquiry from Rajesh Kumar for a round trip from Delhi to Shimla. The customer is looking for a 12-seater Tempo Traveller for a 3-day trip starting from 15th March 2025.\n\nPlease review the details and respond with a quotation as soon as possible.',
    };

    final Color iconColor = notification['color'] ?? AppColors.primaryColor;

    return AppScaffold(
      appBar: const AppHeader(
        title: 'Notification Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notification['icon'] ?? Iconsax.notification, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        notification['title'],
                        style: AppTextStyle.heading,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        notification['time'],
                        style: AppTextStyle.caption,
                        color: AppColors.textColorHint,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            Divider(color: Colors.black.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            
            // Message Body
            AppText(
              'Message Details',
              style: AppTextStyle.subheading,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: AppText(
                notification['fullMessage'] ?? notification['desc'],
                style: AppTextStyle.body,
                fontSize: 15,
                color: AppColors.textColorPrimary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            AppText(
              'Actions',
              style: AppTextStyle.subheading,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 12),
            
            _ActionButton(
              label: 'View Related Details',
              icon: Iconsax.eye,
              onTap: () {
                // Handle navigation to related feature
                Get.snackbar('Coming Soon', 'Navigation to details is being implemented.');
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Mark as Read',
              icon: Iconsax.tick_circle,
              isSecondary: true,
              onTap: () => Get.back(),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Delete Notification',
              icon: Iconsax.trash,
              isDanger: true,
              onTap: () {
                 Get.back();
                 Get.snackbar('Deleted', 'Notification has been removed.');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSecondary;
  final bool isDanger;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSecondary = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.primaryColor;
    if (isDanger) color = Colors.red;
    if (isSecondary) color = AppColors.textColorSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSecondary ? Colors.white : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSecondary ? Colors.black.withValues(alpha: 0.05) : color.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            AppText(
              label,
              style: AppTextStyle.body,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.3), size: 12),
          ],
        ),
      ),
    );
  }
}
