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
import '../controllers/inventory_controller.dart';
import '../domain/models/inventory_model.dart';
import '../../../routes/route_helper.dart';

class InventoryListScreen extends GetView<InventoryController> {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Inventory',
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getAddInventoryItemRoute()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const AppText('Add Item', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search item name or SKU...',
              onChanged: (v) => controller.updateSearch(v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Row(
              children: [
                AppFilterChip(
                  label: 'All',
                  isSelected: controller.selectedFilter.value == 'All',
                  onTap: () => controller.setFilter('All'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'Spare Parts',
                  isSelected: controller.selectedFilter.value == 'Spare Parts',
                  onTap: () => controller.setFilter('Spare Parts'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'Oils & Fluids',
                  isSelected: controller.selectedFilter.value == 'Oils & Fluids',
                  onTap: () => controller.setFilter('Oils & Fluids'),
                ),
              ],
            )),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final lowStockCount = controller.items.where((i) => i.isLowStock).length;
            if (lowStockCount == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.warning_2, color: AppColors.errorColor, size: 20),
                    const SizedBox(width: 8),
                    AppText('$lowStockCount items are low on stock!', style: AppTextStyle.caption, color: AppColors.errorColor, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            );
          }),
          Expanded(
            child: Obx(() {
               if (controller.filteredItems.isEmpty) {
                 return const Center(child: AppText('No inventory items found.'));
               }
               return ListView.builder(
                 padding: const EdgeInsets.all(16),
                 itemCount: controller.filteredItems.length,
                 itemBuilder: (context, index) {
                   return _buildInventoryItem(controller.filteredItems[index]);
                 },
               );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(InventoryModel item) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed(RouteHelper.getInventoryDetailsRoute(), arguments: item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(item.name, style: AppTextStyle.subheading, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(item.category, style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText('SKU: ${item.sku}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Current Stock', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppText('${item.currentStock}', style: AppTextStyle.subheading),
                      if (item.isLowStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const AppText('Low', style: AppTextStyle.caption, color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const AppText('Unit Price', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  const SizedBox(height: 4),
                  AppText('\u20B9 ${item.unitPrice.toStringAsFixed(0)}', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
