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
import '../../membership/views/active_subscription_screen.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/settings_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final SettingsController settingsController = Get.put(SettingsController());
  ProfileController get profileController => Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Vendor Profile',
        subtitle: 'Manage your business details',
      ),
      body: Obx(() {
        final profile = profileController.profile.value;
        final isLoading = profileController.isLoading.value;

        if (isLoading && profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Profile Header ──────────────────────────────────────────
              AppCard(
                child: Row(
                  children: [
                   /* CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(Iconsax.building, color: AppColors.primaryColor, size: 35),
                    ),*/
                  //  NetworkImage(profile!.logoUrl),
                  //   CircleAvatar(
                  //     radius: 35,
                  //     backgroundColor: AppColors.primaryLight,
                  //     child: Text(
                  //       (profile?.companyName != null && profile!.companyName!.isNotEmpty)
                  //           ? profile.companyName![0].toUpperCase()
                  //           : '?',
                  //       style: const TextStyle(
                  //         color: AppColors.primaryColor,
                  //         fontSize: 28,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),


                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: (profile?.logoUrl != null && profile!.logoUrl!.isNotEmpty)
                          ? NetworkImage(profile.logoUrl!)
                          : null,
                      child: (profile?.logoUrl == null || profile!.logoUrl!.isEmpty)
                          ? Text(
                        (profile?.companyName != null && profile!.companyName!.isNotEmpty)
                            ? profile.companyName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),

                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            profile?.companyName ?? 'Loading...',
                            style: AppTextStyle.heading,
                            fontSize: 18,
                          ),
                          AppText(
                            profile?.role == 'admin' ? 'Admin' : 'Premium SaaS Member',
                            style: AppTextStyle.caption,
                          ),
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
                padding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                child: Column(
                  children: [
                    InfoTile(
                      label: 'Owner Name',
                      value: profile?.ownerName ?? '-',
                      icon: Iconsax.user,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(height: 1, indent: 36, color: AppColors.dividerColor),
                    ),
                    InfoTile(
                      label: 'Email Address',
                      value: profile?.email ?? '-',
                      icon: Iconsax.sms,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(height: 1, indent: 36, color: AppColors.dividerColor),
                    ),
                    InfoTile(
                      label: 'Phone Number',
                      value: profile?.phone ?? 'N/A',
                      icon: Iconsax.call,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(height: 1, indent: 36, color: AppColors.dividerColor),
                    ),
                    InfoTile(
                      label: 'GST Number',
                      value: profile?.gstin ?? 'N/A',
                      icon: Icons.assignment_outlined,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(height: 1, indent: 36, color: AppColors.dividerColor),
                    ),
                    InfoTile(
                      label: 'Address',
                      value: profile?.address ?? 'N/A',
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
                      onTap: () => Get.to(() => const ActiveSubscriptionScreen()),
                    ),
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
                      onTap: () => settingsController.showLogoutDialog(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}
