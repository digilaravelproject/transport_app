import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/inventory_controller.dart';
import '../domain/models/inventory_model.dart';
import '../../../routes/route_helper.dart';

class InventoryDetailsScreen extends GetView<InventoryController> {
  const InventoryDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null && controller.items.isEmpty) {
        return const AppScaffold(appBar: AppHeader(title: 'Item Details'), body: Center(child: Text("No item selected")));
    }
    final InventoryModel item = Get.arguments ?? controller.items.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Item Details',
        rightWidget: IconButton(
          icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
          onPressed: () {},
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Stock Out (-)',
                  color: AppColors.errorColor,
                  onPressed: () => Get.toNamed(RouteHelper.getStockOutRoute()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Stock In (+)',
                  color: AppColors.successColor,
                  onPressed: () => Get.toNamed(RouteHelper.getStockInRoute()),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  _buildDetailRow('Reorder Level', '${item.reorderLevel} units'),
                ],
              ),
            ),
             const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 AppText('Recent Activity', style: AppTextStyle.subheading),
                 TextButton(
                  onPressed: () {},
                  child: const AppText('View All', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
               child: Column(
                 children: [
                   _buildActivityRow('Stock In (+10)', '12 May 2024', AppColors.successColor),
                   const Divider(height: 1),
                   _buildActivityRow('Stock Out (-2)', '10 May 2024', AppColors.errorColor),
                   const Divider(height: 1),
                   _buildActivityRow('Stock In (+20)', '01 May 2024', AppColors.successColor),
                 ],
               ),
            )
          ],
        ),
      ),
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
                '${item.currentStock}',
                style: AppTextStyle.heading,
                fontSize: 48,
                color: item.isLowStock ? AppColors.errorColor : AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              AppText('units', style: AppTextStyle.body, color: AppColors.textColorSecondary),
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

  Widget _buildActivityRow(String action, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(action, style: AppTextStyle.body, color: color, fontWeight: FontWeight.bold),
          AppText(date, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
        ],
      ),
    );
  }
}
