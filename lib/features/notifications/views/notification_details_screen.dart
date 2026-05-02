import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({Key? key}) : super(key: key);

  String _formatTime(String createdAt) {
    try {
      final DateTime dateTime = DateTime.parse(createdAt).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return createdAt;
    }
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'finance':
        return Iconsax.empty_wallet;
      case 'lead':
        return Iconsax.user;
      case 'maintenance':
        return Icons.build_rounded;
      case 'trip':
        return Iconsax.bus;
      default:
        return Iconsax.notification;
    }
  }

  Color _getColor(String type) {
    switch (type.toLowerCase()) {
      case 'finance':
        return Colors.green;
      case 'lead':
        return AppColors.primaryColor;
      case 'maintenance':
        return Colors.orange;
      case 'trip':
        return AppColors.primaryColor;
      default:
        return AppColors.textColorSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get notification data from arguments
    final NotificationModel? notification = Get.arguments is NotificationModel ? Get.arguments as NotificationModel : null;

    if (notification == null) {
      return const AppScaffold(
        appBar: AppHeader(title: 'Details', showBackButton: true),
        body: Center(child: AppText('No notification details found')),
      );
    }

    final Color iconColor = _getColor(notification.type);

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
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(notification.type), color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        notification.title,
                        style: AppTextStyle.heading,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        _formatTime(notification.createdAt),
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
            Divider(color: Colors.black.withOpacity(0.05)),
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
                notification.message,
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
                // Handle navigation based on type and data
                if (notification.type == 'finance' && notification.data != null) {
                   Get.snackbar('Finance Detail', 'Navigating to transaction #${notification.data!['entry_id']}');
                } else if (notification.type == 'lead' && notification.data != null) {
                   Get.snackbar('Lead Detail', 'Navigating to lead #${notification.data!['lead_id']}');
                } else {
                   Get.snackbar('Coming Soon', 'Navigation to details is being implemented.');
                }
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Go Back',
              icon: Iconsax.arrow_left,
              isSecondary: true,
              onTap: () => Get.back(),
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
          color: isSecondary ? Colors.white : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSecondary ? Colors.black.withOpacity(0.05) : color.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            AppText(
              label,
              //label,
              style: AppTextStyle.body,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.3), size: 12),
          ],
        ),
      ),
    );
  }
}
