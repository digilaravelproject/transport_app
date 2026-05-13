import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../core/constants/app_text_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/translations/localization_controller.dart';
import '../../../core/widgets/app_bottom_sheet.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final SettingsController settingsController = Get.put(SettingsController());
  ProfileController get profileController => Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.profile.tr,
        subtitle: AppTextConstants.manageBusinessDetails.tr,
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
                      child: (profile?.logoUrl != null && profile!.logoUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: profile.logoUrl!,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => Text(
                                (profile.ownerName != null && profile.ownerName!.isNotEmpty)
                                    ? profile.ownerName![0].toUpperCase()
                                    : (profile.name != null && profile.name!.isNotEmpty)
                                        ? profile.name![0].toUpperCase()
                                        : '?',
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              (profile?.ownerName != null && profile!.ownerName!.isNotEmpty)
                                  ? profile.ownerName![0].toUpperCase()
                                  : (profile?.name != null && profile!.name!.isNotEmpty)
                                      ? profile.name![0].toUpperCase()
                                      : '?',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            profile?.ownerName ?? 'Loading...',
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
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(AppTextConstants.agencyInformation.tr, style: AppTextStyle.subheading),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                child: Column(
                  children: [
                    InfoTile(
                      label: AppTextConstants.ownerNameLabel.tr,
                      value: profile?.ownerName ?? '-',
                      icon: Iconsax.user,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(height: 1, indent: 36, color: AppColors.dividerColor),
                    ),
                    InfoTile(
                      label: AppTextConstants.emailAddress.tr,
                      value: profile?.email ?? '-',
                      icon: Iconsax.sms,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(height: 1, indent: 36, color: AppColors.dividerColor),
                    ),
                    InfoTile(
                      label: AppTextConstants.phone.tr,
                      value: profile?.phone ?? 'N/A',
                      icon: Iconsax.call,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(height: 1, indent: 36, color: AppColors.dividerColor),
                    ),
                    InfoTile(
                      label: AppTextConstants.gstNumber.tr,
                      value: profile?.gstin ?? 'N/A',
                      icon: Icons.assignment_outlined,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(height: 1, indent: 36, color: AppColors.dividerColor),
                    ),
                    InfoTile(
                      label: AppTextConstants.address.tr,
                      value: profile?.address ?? 'N/A',
                      icon: Iconsax.location,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Account Actions ─────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(AppTextConstants.settingsOptions.tr, style: AppTextStyle.subheading),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ActionTile(
                      title: AppTextConstants.subscriptionPlan.tr,
                      subtitle: AppTextConstants.manageCurrentPlan.tr,
                      icon: const Icon(Icons.star_outline_rounded),
                      onTap: () => Get.to(() => const ActiveSubscriptionScreen()),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                    ActionTile(
                      title: AppTextConstants.helpSupport.tr,
                      subtitle: AppTextConstants.faqsSupportContacts.tr,
                      icon: const Icon(Icons.help_outline_rounded),
                      onTap: () => Get.toNamed(RouteHelper.getHelpRoute()),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                    ActionTile(
                      title: AppTextConstants.changeLanguage.tr,
                      subtitle: AppTextConstants.changeAppLanguage.tr,
                      icon: const Icon(Icons.language_rounded),
                      onTap: () => _showLanguageDialog(context),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                    ActionTile(
                      title: AppTextConstants.logout.tr,
                      subtitle: AppTextConstants.logoutSession.tr,
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

  void _showLanguageDialog(BuildContext context) {
    Get.bottomSheet(
      AppBottomSheet(
        title: AppTextConstants.selectLanguage.tr,
        children: AppConstants.languages.map((language) {
          final isSelected = Get.find<LocalizationController>().currentLanguageCode == language.code;
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: Text(
                language.flag,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            title: AppText(
              language.nativeName,
              style: AppTextStyle.body,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            subtitle: AppText(
              language.name.tr,
              style: AppTextStyle.caption,
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor)
                : null,
            onTap: () {
              Get.find<LocalizationController>().setLanguage(language.code);
              Get.back();
            },
          );
        }).toList(),
      ),
    );
  }
}
