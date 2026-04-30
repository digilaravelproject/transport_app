import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/inventory_stocks_controller.dart';
import '../domain/models/stock_transaction_model.dart';

class InventoryStocksScreen extends GetView<InventoryStocksController> {
  const InventoryStocksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Stock History',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.stocks.isEmpty) {
          return const Center(child: AppText('No stock history found.'));
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: controller.stocks.length + (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.stocks.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildStockItem(controller.stocks[index]);
          },
        );
      }),
    );
  }

  Widget _buildStockItem(StockTransactionModel transaction) {
    final bool isStockIn = transaction.transactionType == 'stock_in';
    final Color color = isStockIn ? AppColors.successColor : AppColors.errorColor;
    final String symbol = isStockIn ? '+' : '-';
    
    String formattedDate = '';
    try {
      final date = DateTime.parse(transaction.transactionDate);
      formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      formattedDate = transaction.transactionDate;
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  isStockIn ? 'STOCK IN' : 'STOCK OUT',
                  style: AppTextStyle.caption,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppText(
                '$symbol${transaction.quantity.toStringAsFixed(0)}',
                style: AppTextStyle.subheading,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRow('Date', formattedDate),
          _buildRow('Price', '\u20B9 ${transaction.unitPrice.toStringAsFixed(2)} / unit'),
          _buildRow('Total', '\u20B9 ${transaction.totalPrice.toStringAsFixed(2)}'),
          if (transaction.vendorName != null) _buildRow('Vendor', transaction.vendorName!),
          if (transaction.invoiceNumber != null) _buildRow('Invoice', transaction.invoiceNumber!),
          if (transaction.reason != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            AppText('Reason', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            const SizedBox(height: 4),
            AppText(transaction.reason!, style: AppTextStyle.body),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
          AppText(value, style: AppTextStyle.caption, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
