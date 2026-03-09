import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class SalaryManagementScreen extends GetView<StaffController> {
  const SalaryManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments ?? controller.staffList.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Salary Management',
        subtitle: staff.name,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSalarySummary(staff),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(alignment: Alignment.centerLeft, child: AppText('Salary History', style: AppTextStyle.subheading, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.salaryHistory.length,
                itemBuilder: (context, index) {
                  final record = controller.salaryHistory[index];
                  return _SalaryCard(record: record);
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              text: 'Pay Salary',
              onPressed: () => _showPaymentModal(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalarySummary(StaffModel staff) {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Monthly Salary', style: AppTextStyle.body),
              AppText('₹ ${staff.salaryBalance + staff.advanceTaken}', style: AppTextStyle.heading, fontSize: 18),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryValue('Total Paid', '₹ 25,000', AppColors.successColor),
              _buildSummaryValue('Pending', '₹ ${staff.salaryBalance}', AppColors.errorColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryValue(String label, String value, Color color) {
    return Column(
      children: [
        AppText(value, style: AppTextStyle.subheading, fontSize: 16, color: color, fontWeight: FontWeight.bold),
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
      ],
    );
  }

  void _showPaymentModal() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Pay Salary', style: AppTextStyle.heading, fontSize: 20),
            const SizedBox(height: 24),
            const AppText('Amount to Pay', style: AppTextStyle.label),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: 'Enter amount',
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            AppButton(text: 'Confirm Payment', onPressed: () => Get.back()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SalaryCard extends StatelessWidget {
  final SalaryRecord record;
  const _SalaryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(record.month, style: AppTextStyle.body, fontWeight: FontWeight.bold),
              _buildStatusBadge(record.pendingAmount == 0 ? 'Fully Paid' : 'Partial'),
            ],
          ),
          const Divider(height: 24),
          _buildDetailRow('Total Salary', '₹ ${record.totalSalary}'),
          const SizedBox(height: 8),
          _buildDetailRow('Paid', '₹ ${record.paidAmount}', color: AppColors.successColor),
          const SizedBox(height: 8),
          _buildDetailRow('Pending', '₹ ${record.pendingAmount}', color: AppColors.errorColor),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
        AppText(value, style: AppTextStyle.body, fontSize: 13, color: color, fontWeight: FontWeight.w600),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isPaid = status == 'Fully Paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.successColor : AppColors.warningColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(status, style: AppTextStyle.caption, color: isPaid ? AppColors.successColor : AppColors.warningColor, fontWeight: FontWeight.bold),
    );
  }
}
