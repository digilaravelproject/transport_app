import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routes/route_helper.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Lead: Rajesh Kumar',
        'desc': 'Inquiry for Delhi-Shimla trip on 15th March.',
        'time': '2m ago',
        'isUnread': true,
        'icon': Iconsax.user,
        'color': AppColors.primaryColor,
      },
      {
        'title': 'Payment Received',
        'desc': 'Advance payment of ₹5,000 received for trip #TRS-204.',
        'time': '1h ago',
        'isUnread': true,
        'icon': Iconsax.empty_wallet,
        'color': Colors.green,
      },
      {
        'title': 'Maintenance Reminder',
        'desc': 'Vehicle DL01-1234 service is due in 2 days.',
        'time': '3h ago',
        'isUnread': false,
        'icon': Icons.build_rounded,
        'color': Colors.orange,
      },
      {
        'title': 'Trip Started',
        'desc': 'Trip #TRS-198 to Jaipur has been started by Driver Amar.',
        'time': '5h ago',
        'isUnread': false,
        'icon': Iconsax.bus,
        'color': AppColors.primaryColor,
      },
    ];

    return AppScaffold(
      appBar: const AppHeader(
        title: 'Notifications',
        showBackButton: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return _NotificationCard(
            title: item['title'],
            desc: item['desc'],
            time: item['time'],
            isUnread: item['isUnread'],
            icon: item['icon'],
            iconColor: item['color'],
            onTap: () {
              Get.toNamed(
                RouteHelper.getNotificationDetailsRoute(),
                arguments: item,
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String desc;
  final String time;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.desc,
    required this.time,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        title,
                        style: AppTextStyle.subheading,
                        fontSize: 14,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(
                  desc,
                  style: AppTextStyle.caption,
                  color: AppColors.textColorSecondary,
                  fontSize: 12,
                ),
                const SizedBox(height: 8),
                AppText(
                  time,
                  style: AppTextStyle.caption,
                  color: AppColors.textColorHint,
                  fontSize: 11,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
