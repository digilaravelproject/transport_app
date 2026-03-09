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

class AddInventoryItemScreen extends StatefulWidget {
  const AddInventoryItemScreen({Key? key}) : super(key: key);

  @override
  State<AddInventoryItemScreen> createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final InventoryController controller = Get.find<InventoryController>();
  String _category = 'Spare Parts';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Add Inventory Item',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Item Details', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Item Name',
                    hint: 'e.g. Engine Oil (1L)',
                    icon: Iconsax.box,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown('Category', _category, ['Spare Parts', 'Tools', 'Office Supplies', 'Oils & Fluids'], (val) => setState(() => _category = val!)),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'SKU / Item Code',
                    hint: 'e.g. OIL-1L-001',
                    icon: Icons.qr_code_2_rounded,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: const AppInputField(
                          label: 'Initial Stock',
                          hint: '0',
                          icon: Icons.numbers_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: const AppInputField(
                          label: 'Reorder Level',
                          hint: '10',
                          icon: Iconsax.warning_2,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Unit Price (₹)',
                    hint: '0.00',
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Storage Location',
                    hint: 'e.g. Warehouse A1',
                    icon: Icons.place_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Item',
              onPressed: () {
                Get.snackbar('Success', 'Item added to inventory.', snackPosition: SnackPosition.BOTTOM);
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

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}
