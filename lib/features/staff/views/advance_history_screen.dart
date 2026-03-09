import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class AdvanceHistoryScreen extends GetView<StaffController> {
  const AdvanceHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel? staff = Get.arguments as StaffModel?;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Advance History',
        subtitle: staff?.name ?? 'All Staff',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSummaryCard(),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.advanceHistory.length,
                itemBuilder: (context, index) {
                  final advance = controller.advanceHistory[index];
                  return _AdvanceCard(advance: advance);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Advance', '₹ 15,000', Colors.red),
              _buildSummaryItem('Pending Adjust', '₹ 8,000', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        AppText(value, style: AppTextStyle.heading, fontSize: 20, color: color),
        const SizedBox(height: 4),
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
      ],
    );
  }
}

class _AdvanceCard extends StatelessWidget {
  final AdvancePayment advance;
  const _AdvanceCard({required this.advance});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(advance.staffName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
              AppText('₹ ${advance.amount}', style: AppTextStyle.subheading, fontSize: 16, color: AppColors.errorColor, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 8),
          AppText(advance.reason, style: AppTextStyle.body, fontSize: 13, color: AppColors.textColorSecondary),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Iconsax.calendar_1, size: 14, color: AppColors.textColorHint),
              const SizedBox(width: 8),
              AppText('${advance.date.day}/${advance.date.month}/${advance.date.year}', style: AppTextStyle.caption, color: AppColors.textColorHint),
            ],
          ),
        ],
      ),
    );
  }
}
