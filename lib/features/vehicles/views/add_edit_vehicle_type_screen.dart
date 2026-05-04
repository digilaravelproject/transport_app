import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/vehicle_type_controller.dart';
import '../domain/models/vehicle_type_model.dart';
import 'package:flutter/cupertino.dart';

class AddEditVehicleTypeScreen extends StatefulWidget {
  const AddEditVehicleTypeScreen({Key? key}) : super(key: key);

  @override
  State<AddEditVehicleTypeScreen> createState() => _AddEditVehicleTypeScreenState();
}

class _AddEditVehicleTypeScreenState extends State<AddEditVehicleTypeScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _perKmPriceController = TextEditingController();
  final _acPricePerKmController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<VehicleTypeController>();
  
  VehicleTypeModel? _editingType;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is VehicleTypeModel) {
      _editingType = Get.arguments as VehicleTypeModel;
      _nameController.text = _editingType!.name;
      _descriptionController.text = _editingType!.description ?? '';
      _capacityController.text = _editingType!.capacity.toString();
      _perKmPriceController.text = _editingType!.perKmPrice.toString();
      _acPricePerKmController.text = _editingType!.acPricePerKm.toString();
      _isActive = _editingType!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _perKmPriceController.dispose();
    _acPricePerKmController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'capacity': int.tryParse(_capacityController.text.trim()) ?? 0,
        'per_km_price': double.tryParse(_perKmPriceController.text.trim()) ?? 0.0,
        'ac_price_per_km': double.tryParse(_acPricePerKmController.text.trim()) ?? 0.0,
        'is_active': _isActive ? 1 : 0,
      };

      bool success;
      if (_editingType == null) {
        success = await _controller.addVehicleType(data);
      } else {
        success = await _controller.updateVehicleType(_editingType!.id, data);
      }

      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppHeader(
            title: 'Vehicle Type',
            subtitle: _editingType == null ? 'Add New Type' : 'Edit Type Details',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppInputField(
                          label: 'Type Name *',
                          controller: _nameController,
                          hint: 'e.g. Luxury Bus, Mini Truck',
                          icon: Iconsax.bus,
                          validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppInputField(
                                label: 'Capacity *',
                                controller: _capacityController,
                                hint: '0',
                                icon: Iconsax.user,
                                keyboardType: TextInputType.number,
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppInputField(
                                label: 'Price/KM *',
                                controller: _perKmPriceController,
                                hint: '0.0',
                                icon: Iconsax.money_send,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppInputField(
                          label: 'AC Extra Price/KM',
                          controller: _acPricePerKmController,
                          hint: '0.0',
                          icon: Iconsax.flash,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppInputField(
                          label: 'Description',
                          controller: _descriptionController,
                          hint: 'Additional details about this type...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText('Active Status', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                                AppText('Enable this type for use', style: AppTextStyle.caption),
                              ],
                            ),
                            CupertinoSwitch(
                              value: _isActive,
                              onChanged: (val) => setState(() => _isActive = val),
                              activeColor: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  AppButton(
                    text: _editingType == null ? 'Create Type' : 'Save Changes',
                    onPressed: _save,
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),

        // Loading Overlay
        Obx(() => _controller.isLoading.value 
          ? Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ) 
          : const SizedBox()
        ),
      ],
    );
  }
}
