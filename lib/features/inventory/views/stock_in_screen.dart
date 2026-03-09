import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../controllers/inventory_controller.dart';
import '../domain/models/inventory_model.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({Key? key}) : super(key: key);

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final InventoryController controller = Get.find<InventoryController>();
  InventoryModel? _selectedItem;
  String _supplier = '';

  @override
  void initState() {
    super.initState();
    // Pre-select if navigated from details
    if (Get.arguments is InventoryModel) {
      _selectedItem = Get.arguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Stock In (+)',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Add Stock', style: AppTextStyle.subheading, color: AppColors.successColor),
                  const SizedBox(height: 16),
                  _buildItemDropdown(),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Quantity Added',
                    hint: '0',
                    icon: Iconsax.add,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Date Received',
                    hint: 'DD/MM/YYYY',
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Total Cost (₹)',
                    hint: '0.00',
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Supplier / Vendor',
                    hint: 'e.g. Auto Parts Ltd',
                    icon: Icons.store_mall_directory_outlined,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Bill / Invoice No.',
                    hint: 'e.g. INV-1234',
                    icon: Iconsax.receipt_2_1,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Notes',
                    hint: 'Add details...',
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Stock Update',
              color: AppColors.successColor,
              onPressed: () {
                Get.snackbar('Success', 'Stock inventory updated.', snackPosition: SnackPosition.BOTTOM);
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Cancel',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Select Item', style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<InventoryModel>(
          value: _selectedItem,
          hint: const Text('Choose inventory item'),
          items: controller.items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text('${item.name} (${item.sku})'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedItem = val),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
