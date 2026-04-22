import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
          _buildFilterBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(staff),
                  const SizedBox(height: 24),
                  const AppText('Financial History', style: AppTextStyle.subheading, fontSize: 16, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Obx(() => _buildHistoryList(staff)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              text: 'Pay Salary',
              onPressed: () => _showPaymentModal(staff),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final months = ['All', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final years = ['2023', '2024', '2025'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropDownFilter(
              'Month', 
              controller.selectedSalaryMonth, 
              months
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropDownFilter(
              'Year', 
              controller.selectedSalaryYear, 
              years
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDownFilter(String label, RxString value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary, fontSize: 10, fontWeight: FontWeight.bold),
        const SizedBox(height: 4),
        Obx(() => Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.slate200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primaryColor),
              items: items.map((e) => DropdownMenuItem(value: e, child: AppText(e, style: AppTextStyle.body, fontSize: 13))).toList(),
              onChanged: (val) => value.value = val!,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSummaryCard(StaffModel staff) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(Iconsax.wallet, color: AppColors.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Monthly Salary', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                    AppText('₹ ${staff.salary}', style: AppTextStyle.heading, fontSize: 20),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              _buildSummaryStat('Total Paid', '₹ 25,000', AppColors.successColor),
              Container(width: 1, height: 30, color: AppColors.slate200, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _buildSummaryStat('Pending', '₹ ${staff.salaryBalance}', AppColors.errorColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(value, style: AppTextStyle.subheading, fontSize: 16, color: color, fontWeight: FontWeight.bold),
          AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
        ],
      ),
    );
  }

  Widget _buildHistoryList(StaffModel staff) {
    // Collect and filter records
    final List<dynamic> history = [];
    
    // Filter Salary Records
    for (var record in controller.salaryHistory) {
      bool monthMatch = controller.selectedSalaryMonth.value == 'All' || record.month.contains(controller.selectedSalaryMonth.value);
      bool yearMatch = record.month.contains(controller.selectedSalaryYear.value);
      if (monthMatch && yearMatch) history.add(record);
    }
    
    // Filter Advance Records
    final staffAdvances = controller.advanceHistory.where((a) => a.staffName == staff.name);
    for (var advance in staffAdvances) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      bool monthMatch = controller.selectedSalaryMonth.value == 'All' || months[advance.date.month - 1] == controller.selectedSalaryMonth.value;
      bool yearMatch = advance.date.year.toString() == controller.selectedSalaryYear.value;
      if (monthMatch && yearMatch) history.add(advance);
    }

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Iconsax.info_circle, size: 40, color: AppColors.slate300),
              const SizedBox(height: 12),
              const AppText('No records for the selected period', style: AppTextStyle.body, color: AppColors.textColorSecondary),
            ],
          ),
        ),
      );
    }

    return Column(
      children: history.map((item) {
        if (item is SalaryRecord) {
          return _SalaryCard(record: item);
        } else {
          return _AdvanceCard(advance: item as AdvancePayment);
        }
      }).toList(),
    );
  }

  void _showPaymentModal(StaffModel staff) {
    final pendingAmount = staff.salaryBalance;
    final TextEditingController amountController = TextEditingController(text: pendingAmount.toString());

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Pay Salary', style: AppTextStyle.heading, fontSize: 20),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  _buildModalBalanceRow('Total Salary', '₹ ${staff.salary}'),
                  const SizedBox(height: 8),
                  _buildModalBalanceRow('Advance Taken', '₹ ${staff.salary - pendingAmount}', color: AppColors.warningColor),
                  const Divider(height: 24),
                  _buildModalBalanceRow('Final Pending', '₹ $pendingAmount', color: AppColors.errorColor, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppText('Amount to Pay', style: AppTextStyle.label, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: 'Enter amount',
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor)),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Confirm Payment', 
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Payment Successful', 
                  '₹ ${amountController.text} paid to ${staff.name}',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildModalBalanceRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, color: AppColors.textColorSecondary),
        AppText(value, style: AppTextStyle.body, fontSize: 14, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.w600),
      ],
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.successColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Iconsax.money_send, color: AppColors.successColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(record.month, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                    const AppText('Monthly Salary Payment', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
              _buildStatusBadge(record.pendingAmount == 0 ? 'Paid' : 'Partial'),
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
    bool isPaid = status == 'Paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.successColor : AppColors.warningColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText(status, style: AppTextStyle.caption, color: isPaid ? AppColors.successColor : AppColors.warningColor, fontWeight: FontWeight.bold),
    );
  }
}

class _AdvanceCard extends StatelessWidget {
  final AdvancePayment advance;
  const _AdvanceCard({required this.advance});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${advance.date.day} ${months[advance.date.month-1]} ${advance.date.year}';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.warningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Iconsax.receive_square_2, color: AppColors.warningColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(advance.reason, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                    const AppText('Cash Advance', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
              AppText('₹ ${advance.amount}', style: AppTextStyle.body, color: AppColors.warningColor, fontWeight: FontWeight.bold),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textColorHint),
              const SizedBox(width: 8),
              AppText(dateStr, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
