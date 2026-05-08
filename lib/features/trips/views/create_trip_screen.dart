import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/utils/phone_helper.dart';
import '../controllers/trip_controller.dart';
import '../../../routes/route_helper.dart';
import '../../../core/utils/app_validators.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final controller = Get.find<TripController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? vehicleTypeError;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Create Trip'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Trip Information'),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppInputField(
                      label: 'Trip Date',
                      controller: controller.dateController,
                      hint: 'Select trip date',
                      icon: Iconsax.calendar_1,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          controller.tripDate.value = date;
                          controller.dateController.text = '${date.day}/${date.month}/${date.year}';
                        }
                      },
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Trip Date'),
                    ),
                    const SizedBox(height: 8),
                    AppInputField(
                      label: 'Trip Route',
                      controller: controller.routeController,
                      hint: 'e.g. Delhi to Jaipur',
                      icon: Icons.route_rounded,
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Trip Route'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppInputField(
                            label: 'Duration',
                            controller: controller.durationController,
                            hint: 'e.g. 2 Days',
                            validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Duration'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdown(
                            'Trip Type',
                            controller.selectedTripType,
                            ['One Way', 'Round Trip'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              _buildSectionHeader('Vehicle Information'),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildDropdown(
                      'Vehicle Type',
                      controller.selectedVehicleType,
                      ['Luxury Bus', 'Mini Bus', 'Innova', 'Tempo Traveller'],
                      errorText: vehicleTypeError,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppInputField(
                            label: 'No. of Vehicles',
                            controller: controller.vehicleCountController,
                            hint: 'e.g. 1',
                            keyboardType: TextInputType.number,
                            validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Count'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppInputField(
                            label: 'Capacity',
                            controller: controller.seatingCapacityController,
                            hint: 'e.g. 45',
                            keyboardType: TextInputType.number,
                            validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Capacity'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              _buildSectionHeader('Customer Details (Optional)'),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppInputField(
                      label: 'Customer Name',
                      controller: controller.customerNameController,
                      hint: 'Enter customer name',
                      icon: Iconsax.user,
                    ),
                    const SizedBox(height: 8),
                    Obx(() => AppInputField(
                      label: 'Phone Number',
                      controller: controller.customerPhoneController,
                      hint: 'Enter mobile number',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                      phoneCode: controller.selectedCountryCode.value,
                      onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                        context: context,
                        selectedCode: controller.selectedCountryCode,
                      ),
                      validator: (v) => v != null && v.isNotEmpty ? AppValidators.validateMobile(v) : null,
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              _buildSectionHeader('Payment Details'),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppInputField(
                      label: 'Total Amount',
                      controller: controller.totalAmountController,
                      hint: '0.00',
                      icon: Iconsax.card,
                      keyboardType: TextInputType.number,
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Total Amount'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppInputField(
                            label: 'Advance',
                            controller: controller.advanceAmountController,
                            hint: '0.00',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() {
                            double pending = controller.totalAmount.value - controller.advanceAmount.value;
                            return AppInputField(
                              label: 'Pending',
                              hint: pending.toStringAsFixed(2),
                              readOnly: true,
                              keyboardType: TextInputType.number,
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              AppButton(
                text: 'Save Trip',
                onPressed: () {
                  setState(() => vehicleTypeError = null);
                  bool isValid = formKey.currentState!.validate();
                  if (controller.selectedVehicleType.value.isEmpty) {
                    setState(() => vehicleTypeError = 'Please select vehicle type');
                    isValid = false;
                  }
                  if (isValid) {
                    Get.back();
                  }
                },
              ),
              const SizedBox(height: 8),
              AppButton.outline(
                text: 'Assign Vehicle',
                onPressed: () => Get.toNamed(RouteHelper.getAssignVehicleRoute()),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: AppText(
        title,
        style: AppTextStyle.subheading,
        fontSize: 13,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDropdown(String label, RxString value, List<String> items, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.red : AppColors.slate200),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value.isEmpty ? items.first : value.value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: AppText(item, style: AppTextStyle.body, fontSize: 13),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => vehicleTypeError = null);
                  value.value = newValue;
                }
              },
            ),
          )),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: AppText(errorText, color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }
}
