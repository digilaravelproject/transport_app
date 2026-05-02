import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routes/route_helper.dart';
import '../controllers/notification_controller.dart';
import '../domain/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController controller = Get.put(NotificationController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (controller.hasMore && !controller.isMoreLoading.value) {
          controller.fetchNotifications();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(String createdAt) {
    try {
      final DateTime dateTime = DateTime.parse(createdAt).toLocal();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return DateFormat('dd MMM, hh:mm a').format(dateTime);
      }
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
    return AppScaffold(
      appBar: AppHeader(
        title: 'Notifications',
        showBackButton: true,
        // rightWidget: TextButton(
        // //  onPressed: () => controller.markAllAsRead(),
        //   child: const AppText('Mark all read', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
        // ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        if (controller.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchNotifications(isRefresh: true),
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const Center(child: AppText('No notifications found', style: AppTextStyle.body)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(isRefresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length + (controller.isMoreLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < controller.notifications.length) {
                final NotificationModel item = controller.notifications[index];
                return _NotificationCard(
                  title: item.title,
                  desc: item.message,
                  time: _formatTime(item.createdAt),
                  isUnread: !item.isRead,
                  icon: _getIcon(item.type),
                  iconColor: _getColor(item.type),
                  onTap: () {
                   // controller.markAsRead(item.id);
                    Get.toNamed(
                      RouteHelper.getNotificationDetailsRoute(),
                      arguments: item,
                    );
                  },
                );
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                  ),
                );
              }
            },
          ),
        );
      }),
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
                color: iconColor.withOpacity(0.1),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
