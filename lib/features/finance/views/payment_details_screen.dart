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

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final FinanceController controller = Get.find<FinanceController>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null) {
        if (Get.arguments is int) {
          controller.fetchTransactionDetails(Get.arguments as int);
        } else if (Get.arguments is String) {
           controller.fetchTransactionDetails(int.tryParse(Get.arguments.toString()) ?? 0);
        } else if (Get.arguments is TransactionModel) {
           controller.fetchTransactionDetails((Get.arguments as TransactionModel).id);
        } else {
           // Fallback to first if somehow arguments are passed differently
           if (controller.transactions.isNotEmpty) {
             controller.fetchTransactionDetails(controller.transactions.first.id);
           }
        }
      } else if (controller.transactions.isNotEmpty) {
        controller.fetchTransactionDetails(controller.transactions.first.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Obx(() {
        if (controller.isDetailsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final TransactionModel? transaction = controller.currentTransaction.value;
        if (transaction == null) {
          return const Center(child: AppText("No transaction found"));
        }

        bool isIncome = transaction.type == 'income';
        Color amountColor = isIncome ? AppColors.successColor : AppColors.errorColor;
        String prefix = isIncome ? '+' : '-';

        return SingleChildScrollView(
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
                    _buildDetailRow('Category', transaction.category),
                    _buildDetailRow('Payment Method', transaction.paymentMethod),
                    if (transaction.referenceNo != null) _buildDetailRow('Reference', transaction.referenceNo!),
                    _buildDetailRow('Description', transaction.description),
                    if (transaction.creator != null) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      AppText('Created By', style: AppTextStyle.subheading),
                      const SizedBox(height: 16),
                      _buildDetailRow('Name', transaction.creator!.name),
                      _buildDetailRow('Email', transaction.creator!.email),
                      _buildDetailRow('Role', transaction.creator!.role),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
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
