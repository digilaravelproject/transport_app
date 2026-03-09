import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Fixed Top Bar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (Navigator.of(context).canPop())
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Iconsax.arrow_left_2,
                          color: AppColors.textColorPrimary, size: 20),
                    ),
                  )
                else
                  const SizedBox(width: 36),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.calendar_2, color: AppColors.textColorPrimary, size: 14),
                      SizedBox(width: 4),
                      AppText('This Month',
                          color: AppColors.textColorPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Finance Dashboard',
                          style: AppTextStyle.heading,
                          fontSize: 28,
                          color: AppColors.textColorPrimary,
                        ),
                        SizedBox(height: 4),
                        AppText(
                          'Track revenue, expenses & profitability',
                          style: AppTextStyle.body,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Top Stat Cards Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Revenue',
                            value: '₹12.4L',
                            color: const Color(0xFF10B981),
                            icon: Iconsax.card,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Expenses',
                            value: '₹4.2L',
                            color: const Color(0xFFEF4444),
                            icon: Iconsax.receipt_2_1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Profit',
                            value: '₹8.2L',
                            color: const Color(0xFF3B82F6),
                            icon: Iconsax.trend_up5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pending Card (full width)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.timer_15,
                                color: Color(0xFFF59E0B), size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                '₹ 1,15,000',
                                style: AppTextStyle.heading,
                                fontSize: 22,
                                color: AppColors.textColorPrimary,
                              ),
                              SizedBox(height: 2),
                              AppText(
                                'Pending Payments',
                                style: AppTextStyle.label,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const AppText(
                              'Collect',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AppText(
                      'Financial Overview',
                      style: AppTextStyle.subheading,
                      fontSize: 16,
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Placeholder Chart Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppCard(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.bar_chart_rounded,
                                size: 60,
                                color: AppColors.primaryColor.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            const AppText('Financial Reports & Charts',
                                style: AppTextStyle.subheading),
                            const SizedBox(height: 8),
                            const AppText(
                              'Detailed financial analytics will be shown here.',
                              style: AppTextStyle.caption,
                              align: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          AppText(
            value,
            style: AppTextStyle.heading,
            fontSize: 20,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 4),
          AppText(
            title,
            style: AppTextStyle.label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}
