import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/inventory_controller.dart';
import '../domain/models/inventory_model.dart';
import '../domain/models/stock_transaction_model.dart';
import '../../../routes/route_helper.dart';

class InventoryDetailsScreen extends StatefulWidget {
  const InventoryDetailsScreen({Key? key}) : super(key: key);

  @override
  State<InventoryDetailsScreen> createState() => _InventoryDetailsScreenState();
}

class _InventoryDetailsScreenState extends State<InventoryDetailsScreen> {
  final InventoryController controller = Get.find<InventoryController>();

  @override
  void initState() {
    super.initState();
    final item = Get.arguments;
    if (item is InventoryModel) {
      controller.fetchInventoryDetails(item.id);
    } else if (item is int) {
      controller.fetchInventoryDetails(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Item Details',
        rightWidget: Obx(() {
          final item = controller.currentItem.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
                onPressed: item != null ? () => Get.toNamed(RouteHelper.getAddInventoryItemRoute(), arguments: item) : null,
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.errorColor),
                onPressed: item != null ? () => _showDeleteConfirmation(item.id) : null,
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            final item = controller.currentItem.value;
            return Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Stock Out (-)',
                    color: AppColors.errorColor,
                    onPressed: item != null ? () => Get.toNamed(RouteHelper.getStockOutRoute(), arguments: item) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Stock In (+)',
                    color: AppColors.successColor,
                    onPressed: item != null ? () => Get.toNamed(RouteHelper.getStockInRoute(), arguments: item) : null,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isDetailsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final item = controller.currentItem.value;
        if (item == null) {
          return const Center(child: AppText('Item details not found.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildStockStatusCard(item),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Item Information', style: AppTextStyle.subheading),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _buildDetailRow('Name', item.name),
                    _buildDetailRow('Category', item.category),
                    _buildDetailRow('SKU', item.sku),
                    _buildDetailRow('Unit Price', '\u20B9 ${item.unitPrice.toStringAsFixed(2)}'),
                    _buildDetailRow('Location', item.location),
                    _buildDetailRow('Reorder Level', '${item.reorderLevel.toStringAsFixed(0)} ${item.unit}'),
                    _buildDetailRow('Description', item.description),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText('Recent Activity', style: AppTextStyle.subheading),
                  TextButton(
                    onPressed: () => Get.toNamed(RouteHelper.getStockHistoryRoute(), arguments: item.id),
                    child: const AppText('View All', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                child: controller.recentTransactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: AppText('No recent activity found.')),
                      )
                    : Column(
                        children: controller.recentTransactions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final transaction = entry.value;
                          return Column(
                            children: [
                              _buildActivityRow(transaction),
                              if (index < controller.recentTransactions.length - 1) const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStockStatusCard(InventoryModel item) {
    return AppCard(
      color: item.isLowStock ? AppColors.errorColor.withOpacity(0.05) : AppColors.primaryLight,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AppText(
            item.isLowStock ? 'Low Stock Warning!' : 'Stock Status',
            style: AppTextStyle.body,
            color: item.isLowStock ? AppColors.errorColor : AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppText(
                '${item.currentStock.toStringAsFixed(0)}',
                style: AppTextStyle.heading,
                fontSize: 48,
                color: item.isLowStock ? AppColors.errorColor : AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              AppText(item.unit, style: AppTextStyle.body, color: AppColors.textColorSecondary),
            ],
          ),
          if (item.isLowStock) ...[
            const SizedBox(height: 16),
            const AppText('This item has reached its reorder level. Please re-stock soon.', style: AppTextStyle.caption, color: AppColors.errorColor, textAlign: TextAlign.center),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
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

  Widget _buildActivityRow(StockTransactionModel transaction) {
    final bool isStockIn = transaction.transactionType == 'stock_in';
    final String actionText = isStockIn ? 'Stock In (+${transaction.quantity.toStringAsFixed(0)})' : 'Stock Out (-${transaction.quantity.toStringAsFixed(0)})';
    final Color color = isStockIn ? AppColors.successColor : AppColors.errorColor;
    
    String formattedDate = '';
    try {
      final date = DateTime.parse(transaction.transactionDate);
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      formattedDate = transaction.transactionDate;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(actionText, style: AppTextStyle.body, color: color, fontWeight: FontWeight.bold),
              if (transaction.reason != null && transaction.reason!.isNotEmpty)
                AppText(transaction.reason!, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            ],
          ),
          AppText(formattedDate, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.trash, color: AppColors.errorColor, size: 48),
              const SizedBox(height: 16),
              const AppText('Delete Item', style: AppTextStyle.subheading, fontWeight: FontWeight.bold),
              const SizedBox(height: 12),
              const AppText(
                'Are you sure you want to delete this item? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: AppTextStyle.body,
                color: AppColors.textColorSecondary,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      color: AppColors.textColorSecondary,
                      height: 45,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Delete',
                      onPressed: () async {
                        Get.back(); // Close dialog
                        final success = await controller.deleteItem(id);
                        if (success) {
                          Get.back(); // Return to list screen
                        }
                      },
                      color: AppColors.errorColor,
                      height: 45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
