import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text.dart';
import '../../finance/controllers/finance_controller.dart';
import '../controllers/reports_controller.dart';

class ProfitLossReportScreen extends StatelessWidget {
  const ProfitLossReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensuring both controllers are available
    final financeController = Get.find<FinanceController>();
    final reportsController = Get.find<ReportsController>();

    return AppScaffold(
      appBar: const AppHeader(
        title: 'Profit / Loss Report',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(financeController),
            const SizedBox(height: 24),
            AppText('Income Breakdown', style: AppTextStyle.subheading),
            const SizedBox(height: 12),
            _buildBreakdownList(financeController, 'income'),
            const SizedBox(height: 24),
            AppText('Expense Breakdown', style: AppTextStyle.subheading),
            const SizedBox(height: 12),
            _buildBreakdownList(financeController, 'expense'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(FinanceController controller) {
    return Obx(() {
      final profit = controller.currentBalance;
      final profitColor = profit >= 0 ? AppColors.successColor : AppColors.errorColor;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Income',
                  '\u20B9 ${controller.totalIncome.toStringAsFixed(2)}',
                  Iconsax.arrow_up_3,
                  AppColors.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Expense',
                  '\u20B9 ${controller.totalExpense.toStringAsFixed(2)}',
                  Iconsax.arrow_down,
                  AppColors.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AppText('Net Profit / Loss', style: AppTextStyle.body, color: AppColors.textColorSecondary),
                const SizedBox(height: 8),
                AppText(
                  '\u20B9 ${profit.toStringAsFixed(2)}',
                  style: AppTextStyle.heading,
                  fontSize: 32,
                  color: profitColor,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: profitColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppText(
                    profit >= 0 ? 'Profitable' : 'Loss',
                    style: AppTextStyle.caption,
                    color: profitColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          AppText(title, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
          const SizedBox(height: 4),
          AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildBreakdownList(FinanceController controller, String type) {
    return Obx(() {
      final transactions = controller.transactions.where((t) => t.type == type).toList();
      
      // Group by category
      Map<String, double> categoryTotals = {};
      for (var t in transactions) {
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
      }

      if (categoryTotals.isEmpty) {
        return AppCard(
          padding: const EdgeInsets.all(20),
          child: Center(child: AppText('No data available', style: AppTextStyle.caption)),
        );
      }

      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: categoryTotals.entries.map((entry) {
            return ListTile(
              title: AppText(entry.key, style: AppTextStyle.body),
              trailing: AppText(
                '\u20B9 ${entry.value.toStringAsFixed(2)}',
                style: AppTextStyle.body,
                fontWeight: FontWeight.bold,
                color: type == 'income' ? AppColors.successColor : AppColors.errorColor,
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
