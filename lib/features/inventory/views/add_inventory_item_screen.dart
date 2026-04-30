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
import '../domain/models/inventory_item_request_model.dart';
import '../domain/models/inventory_model.dart';

class AddInventoryItemScreen extends StatefulWidget {
  const AddInventoryItemScreen({Key? key}) : super(key: key);

  @override
  State<AddInventoryItemScreen> createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final InventoryController controller = Get.find<InventoryController>();
  final _formKey = GlobalKey<FormState>();
  
  bool _isEditMode = false;
  int? _itemId;
  String _category = 'Spare Parts';
  String _unit = 'piece';

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _initialStockController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is InventoryModel) {
      _isEditMode = true;
      _itemId = args.id;
      _nameController.text = args.name;
      _skuController.text = args.sku;
      _initialStockController.text = args.currentStock.toStringAsFixed(0);
      _reorderLevelController.text = args.reorderLevel.toStringAsFixed(0);
      _unitPriceController.text = args.unitPrice.toStringAsFixed(2);
      _locationController.text = args.location;
      _descriptionController.text = args.description;
      _category = args.category;
      _unit = args.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _initialStockController.dispose();
    _reorderLevelController.dispose();
    _unitPriceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final request = InventoryItemRequestModel(
        name: _nameController.text.trim(),
        category: _category,
        itemCode: _skuController.text.trim(),
        unit: _unit,
        initialStock: double.tryParse(_initialStockController.text) ?? 0,
        reorderLevel: double.tryParse(_reorderLevelController.text) ?? 0,
        unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
        storageLocation: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (_isEditMode && _itemId != null) {
        await controller.updateItem(_itemId!, request);
      } else {
        await controller.saveItem(request);
      }
    } else {
      Get.snackbar('Error', 'Please fill in all required fields properly', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: _isEditMode ? 'Edit Inventory Item' : 'Add Inventory Item',
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
                    AppText('Item Details', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _nameController,
                      label: 'Item Name',
                      hint: 'e.g. Engine Oil (1L)',
                      icon: Iconsax.box,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Item name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown('Category', _category, ['Spare Parts', 'Tools', 'Office Supplies', 'Oils & Fluids'], (val) => setState(() => _category = val!)),
                    const SizedBox(height: 16),
                    _buildDropdown('Unit', _unit, ['piece', 'litre', 'kg', 'set'], (val) => setState(() => _unit = val!)),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _skuController,
                      label: 'SKU / Item Code',
                      hint: 'e.g. OIL-1L-001',
                      icon: Icons.qr_code_2_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'SKU / Item Code is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppInputField(
                            controller: _initialStockController,
                            label: 'Initial Stock',
                            hint: '0',
                            icon: Icons.numbers_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppInputField(
                            controller: _reorderLevelController,
                            label: 'Reorder Level',
                            hint: '10',
                            icon: Iconsax.warning_2,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _unitPriceController,
                      label: 'Unit Price (₹)',
                      hint: '0.00',
                      icon: Iconsax.card,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Unit price is required';
                        if (double.tryParse(value) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _locationController,
                      label: 'Storage Location',
                      hint: 'e.g. Warehouse A1',
                      icon: Icons.place_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Storage location is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter item description...',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Description is required';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                text: controller.isLoading.value 
                    ? (_isEditMode ? 'Updating...' : 'Saving...') 
                    : (_isEditMode ? 'Update Item' : 'Save Item'),
                onPressed: controller.isLoading.value ? () {} : _saveItem,
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
