import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../controllers/finance_controller.dart';
import '../domain/models/transaction_model.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_empty_state.dart';

class PaymentHistoryScreen extends GetView<FinanceController> {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Payment History',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search category or reference...',
              onChanged: (v) => controller.updateSearch(v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Obx(() => Row(
              children: [
                 AppFilterChip(
                   label: 'All', 
                   isSelected: controller.selectedFilter.value == 'All',
                   onTap: () => controller.setFilter('All'),
                 ),
                 const SizedBox(width: 8),
                 AppFilterChip(
                   label: 'Income', 
                   isSelected: controller.selectedFilter.value == 'Income',
                   onTap: () => controller.setFilter('Income'),
                 ),
                 const SizedBox(width: 8),
                 AppFilterChip(
                   label: 'Expense', 
                   isSelected: controller.selectedFilter.value == 'Expense',
                   onTap: () => controller.setFilter('Expense'),
                 ),
              ],
            )),
          ),
          Expanded(
            child: Obx(() {
               if (controller.filteredTransactions.isEmpty) {
                 return const AppEmptyState(
                   title: 'No Results Found',
                   subtitle: 'We couldn\'t find any transactions matching your search or filters.',
                   icon: Iconsax.search_status,
                 );
               }
               return ListView.builder(
                 padding: const EdgeInsets.all(16),
                 itemCount: controller.filteredTransactions.length,
                 itemBuilder: (context, index) {
                   return _buildTransactionItem(controller.filteredTransactions[index]);
                 },
               );
            }),
          ),
        ],
      ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText('$prefix\u20B9 ${transaction.amount.toStringAsFixed(0)}', style: AppTextStyle.subheading, color: amountColor, fontWeight: FontWeight.bold),
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
