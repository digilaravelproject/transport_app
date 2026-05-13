import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/constants/app_text_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/translations/localization_controller.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useScaffold: false,
      appBar: AppHeader(
        title: AppTextConstants.profile.tr,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Profile Header ──────────────────────────────────────────
            const _ProfileHeader(
              agencyName: 'DigiEmperor Transports',
              ownerName: 'Firoz Mohammad',
            ),
            
            const SizedBox(height: 24),
            
            // ── Agency Info Card ────────────────────────────────────────
            _buildSectionTitle(AppTextConstants.agencyInformation.tr),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: AppTextConstants.agencyNameLabel.tr, value: 'DigiEmperor Transports', icon: Iconsax.building),
                  const Divider(height: 24),
                  _InfoRow(label: AppTextConstants.ownerNameLabel.tr, value: 'Firoz Mohammad', icon: Iconsax.user),
                  const Divider(height: 24),
                  _InfoRow(label: AppTextConstants.phone.tr, value: '+91 9876543210', icon: Iconsax.call),
                  const Divider(height: 24),
                  _InfoRow(label: AppTextConstants.email.tr, value: 'firoz@digiemperor.com', icon: Iconsax.sms),
                  const Divider(height: 24),
                  _InfoRow(label: AppTextConstants.city.tr, value: 'Gurgaon, Haryana', icon: Iconsax.location),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ── Subscription Card ───────────────────────────────────────
            _buildSectionTitle(AppTextConstants.subscriptionPlan.tr),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.primaryColor.withValues(alpha: 0.05),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.star_rounded, color: AppColors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(AppTextConstants.premiumPlan.tr, style: AppTextStyle.subheading, fontSize: 16),
                            AppText('${AppTextConstants.renewsOn.tr} 12 Oct, 2024', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: AppText(AppTextConstants.upgrade.tr, style: AppTextStyle.body, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ── Options List ───────────────────────────────────────────
            _buildSectionTitle(AppTextConstants.settingsOptions.tr),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    label: AppTextConstants.editProfile.tr,
                    icon: Iconsax.edit,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50),
                  _SettingsTile(
                    label: AppTextConstants.changePassword.tr,
                    icon: Iconsax.lock,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50),
                  _SettingsTile(
                    label: AppTextConstants.changeLanguage.tr,
                    icon: Icons.language_rounded,
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const Divider(height: 1, indent: 50),
                  _SettingsTile(
                    label: AppTextConstants.helpSupport.tr,
                    icon: Icons.help_outline_rounded,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50),
                  _SettingsTile(
                    label: AppTextConstants.logout.tr,
                    icon: Iconsax.logout,
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(AppTextConstants.selectLanguage.tr, style: AppTextStyle.heading, fontSize: 18),
            const SizedBox(height: 20),
            ...AppConstants.languages.map((language) {
              return ListTile(
                title: AppText(language.nativeName, style: AppTextStyle.body),
                subtitle: AppText(language.name.tr, style: AppTextStyle.caption),
                onTap: () {
                  Get.find<LocalizationController>().setLanguage(language.code);
                  Get.back();
                },
                trailing: Get.find<LocalizationController>().currentLanguageCode == language.code
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor)
                    : null,
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppText(
        title,
        style: AppTextStyle.subheading,
        fontSize: 14,
        color: AppColors.textColorHint,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String agencyName;
  final String ownerName;

  const _ProfileHeader({
    required this.agencyName,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Iconsax.building, color: AppColors.primaryColor, size: 50),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.camera, color: AppColors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppText(agencyName, style: AppTextStyle.heading, fontSize: 18),
        const SizedBox(height: 4),
        AppText(ownerName, style: AppTextStyle.body, color: AppColors.textColorSecondary),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textColorHint, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label, style: AppTextStyle.caption, color: AppColors.textColorHint),
            AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.w600),
          ],
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.primaryColor, size: 22),
      title: AppText(label, style: AppTextStyle.body, color: textColor),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textColorHint),
    );
  }
}
