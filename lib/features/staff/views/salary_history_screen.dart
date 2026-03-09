import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/models/staff_model.dart';

class SalaryHistoryScreen extends GetView<StaffController> {
  const SalaryHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments ?? controller.staffList.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Salary History',
        subtitle: staff.name,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _SalaryRecordCard(
            date: DateTime.now().subtract(Duration(days: index * 30)),
            amount: staff.salary,
            method: index % 2 == 0 ? 'Bank Transfer' : 'UPI',
            status: 'Paid',
          );
        },
      ),
    );
  }
}

class _SalaryRecordCard extends StatelessWidget {
  final DateTime date;
  final double amount;
  final String method;
  final String status;

  const _SalaryRecordCard({
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.empty_wallet, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('₹ $amount', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText('Paid via $method', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText('${date.day}/${date.month}/${date.year}', style: AppTextStyle.caption),
              const SizedBox(height: 4),
              AppText(status, style: AppTextStyle.caption, color: AppColors.successColor, fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }
}
