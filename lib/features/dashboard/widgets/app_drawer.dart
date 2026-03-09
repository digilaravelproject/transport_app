import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:credit_debit/core/theme/app_colors.dart';
import 'package:credit_debit/core/widgets/app_logo.dart';
import 'package:credit_debit/routes/route_helper.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  static const _items = [
    _DrawerItem(icon: Iconsax.user, label: 'Profile'),
    _DrawerItem(icon: Icons.card_membership_outlined, label: 'Subscription Details'),
    _DrawerItem(icon: Iconsax.notification, label: 'Notifications'),
    _DrawerItem(icon: Icons.help_outline_rounded, label: 'Help & Support'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1D2E) : AppColors.white;

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLogo(size: 64, showShadow: false),
                  const SizedBox(height: 14),
                  const Text(
                    'SDR Agency',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'admin@sdragency.com',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Menu items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _items.length,
                itemBuilder: (_, i) => _DrawerTile(item: _items[i], isDark: isDark),
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: InkWell(
                onTap: () => Get.offAllNamed(RouteHelper.getLoginRoute()),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.logout, color: Color(0xFFB71C1C), size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFB71C1C),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  const _DrawerItem({required this.icon, required this.label});
}

class _DrawerTile extends StatelessWidget {
  final _DrawerItem item;
  final bool isDark;
  const _DrawerTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.back(),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: ListTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: AppColors.primaryColor, size: 20),
          ),
          title: Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.textColorPrimary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.withOpacity(0.5),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
