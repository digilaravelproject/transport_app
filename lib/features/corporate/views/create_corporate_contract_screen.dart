import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/phone_helper.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/vehicle_type_dropdown.dart';
import '../controllers/corporate_controller.dart';
import '../../../core/constants/app_text_constants.dart';
import '../domain/models/corporate_contract_request_model.dart';

class CreateCorporateContractScreen extends StatefulWidget {
  const CreateCorporateContractScreen({Key? key}) : super(key: key);

  @override
  State<CreateCorporateContractScreen> createState() => _CreateCorporateContractScreenState();
}

class _CreateCorporateContractScreenState extends State<CreateCorporateContractScreen> {
  final CorporateController controller = Get.find<CorporateController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _contractNameController = TextEditingController();
  final TextEditingController _contractNumberController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _monthlyAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final selectedVehicleType = ''.obs;
  final selectedVehicleTypeId = Rxn<int>();
  final vehicleTypeError = Rxn<String>();

  String _dutyType = AppTextConstants.dailyCommute.tr;

  @override
  void dispose() {
    _vendorNameController.dispose();
    _contractNameController.dispose();
    _contractNumberController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _quantityController.dispose();
    _monthlyAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Clear error if dates are being selected
      _formKey.currentState?.validate();
    }
  }

  void _saveContract() async {
    // Clear previous custom errors
    vehicleTypeError.value = null;

    if (_formKey.currentState!.validate()) {
      // Custom validation for vehicle type
      if (selectedVehicleTypeId.value == null) {
        vehicleTypeError.value = AppTextConstants.pleaseSelectVehicleType.tr;
        return;
      }

      // Logical validation for dates
      final startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      final endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);
      if (endDate.isBefore(startDate)) {
        CustomSnackbar.showError(AppTextConstants.endDateBeforeStartDateError.tr);
        return;
      }

      final request = CorporateContractRequestModel(
        name: _contractNameController.text.trim(),
        vendorName: _vendorNameController.text.trim(),
        contractNumber: _contractNumberController.text.trim(),
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        dutyType: _dutyType,
        vehicleType: selectedVehicleTypeId.value ?? 0,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        monthlyAmount: double.tryParse(_monthlyAmountController.text) ?? 0.0,
        notes: _notesController.text.trim(),
      );

      final success = await controller.createContract(request);
      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.createContract.tr,
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
                    AppText(AppTextConstants.contractDetails.tr, style: AppTextStyle.subheading, color: AppColors.primaryColor),
                    const SizedBox(height: 8),
                    AppInputField(
                      controller: _vendorNameController,
                      label: AppTextConstants.vendorName.tr,
                      hint: AppTextConstants.enterVendorName.tr,
                      icon: Iconsax.building,
                      isRequired: true,
                      validator: (value) => (value == null || value.isEmpty) ? AppTextConstants.vendorNameRequired.tr : null,
                    ),
                    const SizedBox(height: 8),
                    AppInputField(
                      controller: _contractNameController,
                      label: AppTextConstants.contractName.tr,
                      hint: 'e.g. Employee Transport 2024',
                      icon: Icons.assignment_rounded,
                      isRequired: true,
                      validator: (value) => (value == null || value.isEmpty) ? AppTextConstants.contractNameRequired.tr : null,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => AppInputField(
                      controller: _contractNumberController,
                      label: AppTextConstants.contractNumber.tr,
                      hint: 'Enter 10 digit number',
                      icon: Iconsax.call,
                      isRequired: true,
                      validator: AppValidators.validateMobile,
                      keyboardType: TextInputType.number,
                      phoneCode: controller.selectedCountryCode.value,
                      onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                        context: context,
                        selectedCode: controller.selectedCountryCode,
                      ),
                    )),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppInputField(
                            controller: _startDateController,
                            label: AppTextConstants.startDate.tr,
                            hint: 'YYYY-MM-DD',
                            icon: Iconsax.calendar_1,
                            readOnly: true,
                            onTap: () => _selectDate(context, _startDateController),
                            isRequired: true,
                            validator: (value) => (value == null || value.isEmpty) ? AppTextConstants.required.tr : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppInputField(
                            controller: _endDateController,
                            label: AppTextConstants.endDate.tr,
                            hint: 'YYYY-MM-DD',
                            icon: Icons.event_rounded,
                            readOnly: true,
                            onTap: () => _selectDate(context, _endDateController),
                            isRequired: true,
                            validator: (value) => (value == null || value.isEmpty) ? AppTextConstants.required.tr : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(AppTextConstants.dutyType.tr, _dutyType, [AppTextConstants.dailyCommute.tr, AppTextConstants.eventTransfer.tr, AppTextConstants.customRoute.tr, AppTextConstants.schoolDuty.tr], (val) => setState(() => _dutyType = val!)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          flex: 2,
                          child: Obx(() => VehicleTypeDropdown(
                            selectedId: selectedVehicleTypeId,
                            errorText: vehicleTypeError.value,
                            onChanged: (id, displayName) {
                              selectedVehicleType.value = displayName;
                              vehicleTypeError.value = null; // Clear error on selection
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppInputField(
                            controller: _quantityController,
                            label: AppTextConstants.quantity.tr,
                            hint: '0',
                            icon: Iconsax.truck_fast,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) return AppTextConstants.required.tr;
                              if (int.tryParse(value) == null) return AppTextConstants.invalid.tr;
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppInputField(
                      controller: _monthlyAmountController,
                      label: AppTextConstants.monthlySalary.tr,
                      hint: '₹ 0.00',
                      icon: Iconsax.card,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return AppTextConstants.required.tr;
                        if (double.tryParse(value) == null) return AppTextConstants.invalid.tr;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppInputField(
                      controller: _notesController,
                      label: AppTextConstants.notes.tr,
                      hint: AppTextConstants.additionalNotesHint.tr,
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                text: AppTextConstants.saveContract.tr,
                isLoading: controller.isLoading.value,
                onPressed: _saveContract,
              )),
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
        const SizedBox(height: 6),
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
  }
}
