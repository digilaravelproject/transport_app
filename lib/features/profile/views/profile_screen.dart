import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useScaffold: false,
      appBar: const AppHeader(
        title: 'Profile',
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
            _buildSectionTitle('Agency Information'),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  _InfoRow(label: 'Agency Name', value: 'DigiEmperor Transports', icon: Iconsax.building),
                  Divider(height: 24),
                  _InfoRow(label: 'Owner Name', value: 'Firoz Mohammad', icon: Iconsax.user),
                  Divider(height: 24),
                  _InfoRow(label: 'Phone', value: '+91 9876543210', icon: Iconsax.call),
                  Divider(height: 24),
                  _InfoRow(label: 'Email', value: 'firoz@digiemperor.com', icon: Iconsax.sms),
                  Divider(height: 24),
                  _InfoRow(label: 'City', value: 'Gurgaon, Haryana', icon: Iconsax.location),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ── Subscription Card ───────────────────────────────────────
            _buildSectionTitle('Subscription Plan'),
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
                          children: const [
                            AppText('Premium Plan', style: AppTextStyle.subheading, fontSize: 16),
                            AppText('Renews on 12 Oct, 2024', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const AppText('Upgrade', style: AppTextStyle.body, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ── Options List ───────────────────────────────────────────
            _buildSectionTitle('Settings & Options'),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    label: 'Edit Profile',
                    icon: Iconsax.edit,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50),
                  _SettingsTile(
                    label: 'Change Password',
                    icon: Iconsax.lock,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50),
                  _SettingsTile(
                    label: 'Language',
                    icon: Icons.language_rounded,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50),
                  _SettingsTile(
                    label: 'Help & Support',
                    icon: Icons.help_outline_rounded,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50),
                  _SettingsTile(
                    label: 'Logout',
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
