import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/action_tile.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Help & Support',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const AppCard(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.support_agent_rounded, size: 48, color: AppColors.primaryColor),
                  SizedBox(height: 16),
                  AppText('We are here to help you!', style: AppTextStyle.subheading, textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  AppText('Find answers to common questions or reach out to our dedicated support team directly.', style: AppTextStyle.body, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText('Contact Us', style: AppTextStyle.subheading),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ActionTile(
                    title: 'Email Support',
                    subtitle: 'support@digiemperor.com',
                    icon: const Icon(Iconsax.sms),
                    onTap: () => launchUrl(Uri.parse('mailto:support@digiemperor.com')),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  ActionTile(
                    title: 'Call Support',
                    subtitle: '+91 1800-123-4567',
                    icon: const Icon(Iconsax.call),
                    onTap: () => launchUrl(Uri.parse('tel:+9118001234567')),
                  ),
                   const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  ActionTile(
                    title: 'WhatsApp Support',
                    subtitle: 'Chat with us',
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),
             const SizedBox(height: 32),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText('Resources', style: AppTextStyle.subheading),
            ),
             const SizedBox(height: 12),
             AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ActionTile(
                    title: 'Frequently Asked Questions',
                    subtitle: 'Browse common issues and answers',
                    icon: const Icon(Icons.live_help_outlined),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.dividerColor),
                  ActionTile(
                    title: 'User Manual & Documentation',
                    subtitle: 'Read our comprehensive guides',
                    icon: const Icon(Icons.menu_book_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const AppText('App Version 1.0.0 (Build 12)', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
