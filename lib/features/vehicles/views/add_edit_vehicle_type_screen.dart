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
import '../../../core/constants/app_text_constants.dart';

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
    // Determine if arguments contain a VehicleTypeModel (already passed) or an ID integer
    final args = Get.arguments;
    if (args is VehicleTypeModel) {
      _editingType = args;
      _populateFields(_editingType!);
    } else if (args is int) {
      // Fetch vehicle type details from API
      _controller.fetchVehicleTypeById(args);
      // Listen for when data becomes available
      ever(_controller.selectedVehicle, (VehicleTypeModel? type) {
        if (type != null) {
          _editingType = type;
          _populateFields(type);
        }
      });
    }
  }

  void _populateFields(VehicleTypeModel type) {
    _nameController.text = type.name;
    _descriptionController.text = type.description ?? '';
    _capacityController.text = type.capacity.toString();
    _perKmPriceController.text = type.perKmPrice.toString();
    _acPricePerKmController.text = type.acPricePerKm.toString();
    _isActive = type.isActive;
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
        'price_per_km': double.tryParse(_perKmPriceController.text.trim()) ?? 0.0,
        'ac_extra_price': double.tryParse(_acPricePerKmController.text.trim()) ?? 0.0,
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
            title: AppTextConstants.vehicleType.tr,
            subtitle: _editingType == null ? AppTextConstants.addNewType.tr : AppTextConstants.editTypeDetails.tr,
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
                          label: AppTextConstants.typeName.tr,
                          controller: _nameController,
                          hint: AppTextConstants.typeNameHint.tr,
                          icon: Iconsax.bus,
                          validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppInputField(
                                label: AppTextConstants.capacityRequired.tr,
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
                                label: '${AppTextConstants.pricePerKm.tr} *',
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
                          label: AppTextConstants.acExtraPricePerKm.tr,
                          controller: _acPricePerKmController,
                          hint: '0.0',
                          icon: Iconsax.flash,
                          validator: (val) => val == null || val.isEmpty ? AppTextConstants.priceIsRequired.tr : null,
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
                          label: AppTextConstants.description.tr,
                          controller: _descriptionController,
                          hint: AppTextConstants.descriptionHint.tr,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(AppTextConstants.activeStatus.tr, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                                AppText(AppTextConstants.enableTypeForUse.tr, style: AppTextStyle.caption),
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
                    text: _editingType == null ? AppTextConstants.createType.tr : AppTextConstants.saveChanges.tr,
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
