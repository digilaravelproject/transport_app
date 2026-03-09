import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/finance_controller.dart';
import '../domain/models/transaction_model.dart';
import '../../../routes/route_helper.dart';

class CashbookDashboardScreen extends GetView<FinanceController> {
  const CashbookDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Cashbook',
        rightWidget: IconButton(
          icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primaryColor),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildBalanceCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Recent Transactions', style: AppTextStyle.subheading),
                TextButton(
                  onPressed: () {},
                  child: const AppText('View All', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.transactions.isEmpty) {
                return const Center(child: AppText('No transactions yet.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionItem(controller.transactions[index]);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Obx(() {
      return AppCard(
        color: AppColors.primaryColor,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppText('Current Balance', style: AppTextStyle.body, color: Colors.white70),
            const SizedBox(height: 8),
            AppText('\u20B9 ${controller.currentBalance.toStringAsFixed(2)}', style: AppTextStyle.heading, fontSize: 36, color: Colors.white),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const AppText('Total In', style: AppTextStyle.caption, color: Colors.white70),
                        const SizedBox(height: 4),
                        AppText('\u20B9 ${controller.totalIncome.toStringAsFixed(0)}', style: AppTextStyle.subheading, color: AppColors.successColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const AppText('Total Out', style: AppTextStyle.caption, color: Colors.white70),
                        const SizedBox(height: 4),
                        AppText('\u20B9 ${controller.totalExpense.toStringAsFixed(0)}', style: AppTextStyle.subheading, color: AppColors.errorColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(RouteHelper.getCashInEntryRoute()),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.successColor.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.arrow_downward_rounded, color: AppColors.successColor),
                  SizedBox(height: 8),
                  AppText('Cash In', style: AppTextStyle.body, color: AppColors.successColor, fontWeight: FontWeight.bold),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(RouteHelper.getCashOutEntryRoute()),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.arrow_upward_rounded, color: AppColors.errorColor),
                  SizedBox(height: 8),
                  AppText('Cash Out', style: AppTextStyle.body, color: AppColors.errorColor, fontWeight: FontWeight.bold),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    bool isIncome = transaction.type == 'income';
    Color amountColor = isIncome ? AppColors.successColor : AppColors.errorColor;
    String prefix = isIncome ? '+' : '-';
    IconData icon = isIncome ? Iconsax.document_download : Iconsax.document_upload;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed(RouteHelper.getPaymentDetailsRoute(), arguments: transaction),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: amountColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(transaction.category, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText('${transaction.date.day}/${transaction.date.month}/${transaction.date.year} • ${transaction.paymentMethod}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          AppText('$prefix\u20B9 ${transaction.amount.toStringAsFixed(0)}', style: AppTextStyle.subheading, color: amountColor, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
