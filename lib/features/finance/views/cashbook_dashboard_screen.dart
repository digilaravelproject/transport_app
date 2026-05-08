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
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_empty_state.dart';

class CashbookDashboardScreen extends GetView<FinanceController> {
  const CashbookDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Cashbook',
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: _buildQuickActions(),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshFinanceData(),
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildBalanceCard(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText('Recent Transactions', style: AppTextStyle.subheading),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(RouteHelper.getPaymentHistoryRoute());
                      },
                      child: const AppText(
                        'View All',
                        style: AppTextStyle.caption,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRecentTransactions(),
                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecentTransactions() {
    return Obx(() {
      final recentTransactions = controller.recentTransactions;
      
      if (recentTransactions.isEmpty) {
        return const AppEmptyState(
          title: 'No Transactions Yet',
          subtitle: 'Start by adding your first income or expense to track your cash flow.',
          icon: Iconsax.receipt_item,
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentTransactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionItem(recentTransactions[index]);
        },
      );
    });
  }

  Widget _buildBalanceCard() {
    return Obx(() {
      return AppCard(
        color: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Current Balance', style: AppTextStyle.caption, color: Colors.white70),
                    const SizedBox(height: 4),
                    AppText('\u20B9 ${controller.currentBalance.toStringAsFixed(2)}', 
                        style: AppTextStyle.heading, fontSize: 28, color: Colors.white),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.wallet_1, color: Colors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, color: AppColors.successColor, size: 16),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Total In', style: AppTextStyle.caption, color: Colors.white70, fontSize: 10),
                            AppText('\u20B9 ${controller.totalIncome.toStringAsFixed(0)}', 
                                style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(height: 30, width: 1, color: Colors.white12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: AppColors.errorColor, size: 16),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Total Out', style: AppTextStyle.caption, color: Colors.white70, fontSize: 10),
                            AppText('\u20B9 ${controller.totalExpense.toStringAsFixed(0)}', 
                                style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          child: AppButton(
            text: 'Cash In',
            color: AppColors.successColor,
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.toNamed(RouteHelper.getCashInEntryRoute()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: 'Cash Out',
            color: AppColors.errorColor,
            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.toNamed(RouteHelper.getCashOutEntryRoute()),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    bool isIncome = transaction.entryType == 'income';
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
                AppText(
                  transaction.displayCategory,
                  style: AppTextStyle.body,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                AppText(
                  '${transaction.entryDate.day}/${transaction.entryDate.month}/${transaction.entryDate.year} • ${transaction.paymentMethod}',
                  style: AppTextStyle.caption,
                  color: AppColors.textColorSecondary,
                ),
                if (transaction.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  AppText(
                    transaction.description,
                    style: AppTextStyle.caption,
                    color: AppColors.textColorSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '$prefix\u20B9 ${transaction.amount.toStringAsFixed(0)}',
                style: AppTextStyle.subheading,
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
              if (transaction.receiptPath != null && transaction.receiptPath!.isNotEmpty) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getDocumentPreviewRoute(), 
                    arguments: AppConstants.getFileUrl(transaction.receiptPath)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.eye, size: 16, color: AppColors.primaryColor),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
