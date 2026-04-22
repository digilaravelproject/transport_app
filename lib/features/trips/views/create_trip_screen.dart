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

class CreateTripScreen extends GetView<TripController> {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Create Trip'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Trip Information'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
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
                    child: AbsorbPointer(
                      child: AppInputField(
                        label: 'Trip Date',
                        controller: controller.dateController,
                        hint: 'Select trip date',
                        icon: Iconsax.calendar_1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Trip Route',
                    controller: controller.routeController,
                    hint: 'e.g. Delhi to Jaipur',
                    icon: Icons.route_rounded,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppInputField(
                          label: 'Duration',
                          controller: controller.durationController,
                          hint: 'e.g. 2 Days',
                        ),
                      ),
                      const SizedBox(width: 12),
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
            
            const SizedBox(height: 24),
            _buildSectionHeader('Vehicle Information'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDropdown(
                    'Vehicle Type',
                    controller.selectedVehicleType,
                    ['Luxury Bus', 'Mini Bus', 'Innova', 'Tempo Traveller'],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppInputField(
                          label: 'No. of Vehicles',
                          controller: controller.vehicleCountController,
                          hint: 'e.g. 1',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppInputField(
                          label: 'Capacity',
                          controller: controller.seatingCapacityController,
                          hint: 'e.g. 45',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Customer Details (Optional)'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppInputField(
                    label: 'Customer Name',
                    controller: controller.customerNameController,
                    hint: 'Enter customer name',
                    icon: Iconsax.user,
                  ),
                  const SizedBox(height: 16),
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
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Payment Details'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppInputField(
                    label: 'Total Amount',
                    controller: controller.totalAmountController,
                    hint: '0.00',
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
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
                      const SizedBox(width: 12),
                      const Expanded(
                        child: AppInputField(
                          label: 'Pending',
                          hint: '0.00',
                          readOnly: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Trip',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Assign Vehicle',
              onPressed: () => Get.toNamed(RouteHelper.getAssignVehicleRoute()),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: AppText(
        title,
        style: AppTextStyle.subheading,
        fontSize: 14,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDropdown(String label, RxString value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value.isEmpty ? items.first : value.value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: AppText(item, style: AppTextStyle.body),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) value.value = newValue;
              },
            ),
          )),
        ),
      ],
    );
  }
}
