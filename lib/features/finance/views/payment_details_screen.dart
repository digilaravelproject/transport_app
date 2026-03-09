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

class PaymentDetailsScreen extends GetView<FinanceController> {
  const PaymentDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null && controller.transactions.isEmpty) {
        return const AppScaffold(appBar: AppHeader(title: 'Payment Details'), body: Center(child: Text("No transaction selected")));
    }
    final TransactionModel transaction = Get.arguments ?? controller.transactions.first;
    bool isIncome = transaction.type == 'income';
    Color amountColor = isIncome ? AppColors.successColor : AppColors.errorColor;
    String prefix = isIncome ? '+' : '-';

    return AppScaffold(
      appBar: AppHeader(
        title: 'Payment Details',
        rightWidget: IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.primaryColor),
          onPressed: () {},
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AppButton(
            text: 'Download Receipt',
            onPressed: () {
              Get.snackbar('Download Started', 'Receipt is being downloaded...', snackPosition: SnackPosition.BOTTOM);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                   Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: amountColor.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isIncome ? Iconsax.document_download : Iconsax.document_upload,
                      color: amountColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppText('Transaction Successful', style: AppTextStyle.caption, color: amountColor, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  AppText('$prefix\u20B9 ${transaction.amount.toStringAsFixed(2)}', style: AppTextStyle.heading, fontSize: 32, color: amountColor),
                  const SizedBox(height: 8),
                  AppText(transaction.date.toIso8601String().substring(0, 10), style: AppTextStyle.body, color: AppColors.textColorSecondary),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Transaction Details', style: AppTextStyle.subheading),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildDetailRow('Transaction ID', transaction.id),
                  _buildDetailRow('Category', transaction.category),
                  _buildDetailRow('Payment Method', transaction.paymentMethod),
                  if (transaction.referenceNo != null) _buildDetailRow('Reference', transaction.referenceNo!),
                  _buildDetailRow('Description', transaction.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary),
          ),
          Expanded(
            flex: 3,
            child: AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.bold, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
