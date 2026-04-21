import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../core/widgets/action_tile.dart';
import '../../../routes/route_helper.dart';
import '../controllers/settings_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Vendor Profile',
        subtitle: 'Manage your business details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() => Column(
          children: [
            // ── Profile Header ──────────────────────────────────────────
            AppCard(
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Iconsax.building, color: AppColors.primaryColor, size: 35),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(controller.agencyName.value, style: AppTextStyle.heading, fontSize: 18),
                        const AppText('Premium SaaS Member', style: AppTextStyle.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
                    onPressed: () => Get.toNamed(RouteHelper.getEditProfileRoute()),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ── Agency Information ──────────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText('Agency Information', style: AppTextStyle.subheading),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  InfoTile(
                    label: 'Email Address',
                    value: controller.email.value,
                    icon: Iconsax.sms,
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  InfoTile(
                    label: 'Phone Number',
                    value: controller.phone.value,
                    icon: Iconsax.call,
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  InfoTile(
                    label: 'GST Number',
                    value: controller.gstNumber.value,
                    icon: Icons.assignment_outlined,
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  InfoTile(
                    label: 'Address',
                    value: controller.address.value,
                    icon: Iconsax.location,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Account Actions ─────────────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText('Account Settings', style: AppTextStyle.subheading),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ActionTile(
                    title: 'Subscription Plan',
                    subtitle: 'Manage your current plan',
                    icon: const Icon(Icons.star_outline_rounded),
                    onTap: () => Get.toNamed(RouteHelper.getSubscriptionRoute()),
                  ),
                  // const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  // ActionTile(
                  //   title: 'Change Password',
                  //   subtitle: 'Update your login credentials',
                  //   icon: const Icon(Iconsax.lock),
                  //   onTap: () => Get.toNamed(RouteHelper.getChangePasswordRoute()),
                  // ),
                  const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  ActionTile(
                    title: 'Help & Support',
                    subtitle: 'FAQs and support contacts',
                    icon: const Icon(Icons.help_outline_rounded),
                    onTap: () => Get.toNamed(RouteHelper.getHelpRoute()),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  ActionTile(
                    title: 'Sign Out',
                    subtitle: 'Logout from this session',
                    icon: const Icon(Iconsax.logout),
                    iconColor: AppColors.errorColor,
                    onTap: () => controller.logout(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        )),
      ),
    );
  }
}
