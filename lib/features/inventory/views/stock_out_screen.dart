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
  final _formKey = GlobalKey<FormState>();

  InventoryModel? _selectedItem;
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Pre-select if navigated from details
    if (Get.arguments is InventoryModel) {
      _selectedItem = Get.arguments;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _vehicleController.dispose();
    _assignedToController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveStockUpdate() async {
    if (_selectedItem == null) {
      Get.snackbar('Error', 'Please select an item', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      if (quantity > _selectedItem!.currentStock) {
        Get.snackbar('Error', 'Insufficient stock! Current stock: ${_selectedItem!.currentStock}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final Map<String, dynamic> data = {
        'quantity': quantity,
        'unit_price': double.tryParse(_priceController.text) ?? 0.0,
        'transaction_date': _dateController.text,
        'vehicle_assigned': _vehicleController.text,
        'assigned_to': _assignedToController.text,
        'reason': _reasonController.text,
      };

      await controller.stockOut(_selectedItem!.id, data);
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
        child: Form(
          key: _formKey,
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
                    AppInputField(
                      label: 'Quantity Used',
                      hint: '0',
                      controller: _quantityController,
                      icon: Icons.remove_circle_outline_rounded,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final qty = int.tryParse(v);
                        if (qty == null || qty <= 0) return 'Invalid quantity';
                        if (_selectedItem != null && qty > _selectedItem!.currentStock) {
                          return 'Cannot exceed available stock (${_selectedItem!.currentStock})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Unit Price (₹)',
                      hint: '0.00',
                      controller: _priceController,
                      icon: Iconsax.card,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      isRequired: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Date Used',
                      hint: 'YYYY-MM-DD',
                      controller: _dateController,
                      icon: Iconsax.calendar_1,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Vehicle Assigned (Optional)',
                      hint: 'e.g. MH 12 AB 1234',
                      controller: _vehicleController,
                      icon: Iconsax.bus,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Assigned To (Mechanic/Driver)',
                      hint: 'e.g. John Doe',
                      controller: _assignedToController,
                      icon: Iconsax.user,
                      isRequired: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Reason / Notes',
                      hint: 'Add details...',
                      controller: _reasonController,
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                      isRequired: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                text: 'Save Stock Update',
                color: AppColors.errorColor,
                isLoading: controller.isLoading.value,
                onPressed: _saveStockUpdate,
              )),
              const SizedBox(height: 12),
              AppButton.outline(
                text: 'Cancel',
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemDropdown() {
    return Obx(() {
      final items = controller.items;
      
      // Ensure the selected item is actually in the list (matching by equality override)
      InventoryModel? selectedValue;
      if (_selectedItem != null) {
        try {
          selectedValue = items.firstWhere((element) => element == _selectedItem);
        } catch (e) {
          selectedValue = null;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Select Item',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<InventoryModel>(
            value: selectedValue,
            hint: const Text('Choose inventory item'),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text('${item.name} (${item.sku})'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => _selectedItem = val);
            },
            validator: (v) => v == null ? 'Required' : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.slate50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      );
    });
  }
}
