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

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({Key? key}) : super(key: key);

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final InventoryController controller = Get.find<InventoryController>();
  InventoryModel? _selectedItem;

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
        title: 'Stock Out (-)',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Remove / Use Stock', style: AppTextStyle.subheading, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  _buildItemDropdown(),
                  if (_selectedItem != null) ...[
                    const SizedBox(height: 8),
                    AppText('Current Stock: ${_selectedItem!.currentStock} units', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  ],
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Quantity Used',
                    hint: '0',
                    icon: Icons.remove_circle_outline_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Date Used',
                    hint: 'DD/MM/YYYY',
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Vehicle Assigned (Optional)',
                    hint: 'e.g. MH 12 AB 1234',
                    icon: Iconsax.bus,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Assigned To (Mechanic/Driver)',
                    hint: 'e.g. John Doe',
                    icon: Iconsax.user,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Reason / Notes',
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
              color: AppColors.errorColor,
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
