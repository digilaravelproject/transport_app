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
import '../../../core/widgets/vehicle_type_dropdown.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/utils/phone_helper.dart';
import '../controllers/trip_controller.dart';
import '../../routes_management/views/location_search_screen.dart';
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
  Map<String, dynamic>? _pickupPoint;
  final List<TextEditingController> _destinationControllers = [];
  final List<Map<String, dynamic>?> _destinationPoints = [];

  @override
  void initState() {
    super.initState();
    _destinationControllers.add(TextEditingController());
    _destinationPoints.add(null);
  }

  @override
  void dispose() {
    for (var c in _destinationControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addDestination() {
    setState(() {
      _destinationControllers.add(TextEditingController());
      _destinationPoints.add(null);
    });
  }

  void _removeDestination(int index) {
    if (_destinationControllers.length > 1) {
      setState(() {
        _destinationControllers[index].dispose();
        _destinationControllers.removeAt(index);
        _destinationPoints.removeAt(index);
      });
    }
  }

  Future<void> _selectLocation(int? index) async {
    final result = await Get.to(() => const LocationSearchScreen(title: 'Search Location'));
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (index == null) {
          _pickupPoint = result;
          controller.pickupAddressController.text = result['name'];
        } else {
          _destinationPoints[index] = result;
          _destinationControllers[index].text = result['name'];
        }
      });
    }
  }

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
              const SectionHeader(title: 'Trip Information'),
              const SizedBox(height: 8),
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
                    const SizedBox(height: 12),
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
              
              const SizedBox(height: 16),
              const SectionHeader(title: 'Route Details'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppInputField(
                      label: 'Pickup Point',
                      hint: 'Search pickup location',
                      icon: Iconsax.location,
                      controller: controller.pickupAddressController,
                      readOnly: true,
                      onTap: () => _selectLocation(null),
                      validator: (val) => (val == null || val.isEmpty) ? 'Pickup point required' : null,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_destinationControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppInputField(
                                label: index == _destinationControllers.length - 1 ? 'End Point' : 'Stop Point ${index + 1}',
                                hint: 'Search destination',
                                icon: Iconsax.map,
                                controller: _destinationControllers[index],
                                readOnly: true,
                                onTap: () => _selectLocation(index),
                                validator: (val) => (val == null || val.isEmpty) ? 'Destination required' : null,
                              ),
                            ),
                            if (_destinationControllers.length > 1)
                              IconButton(
                                icon: const Icon(Iconsax.trash, color: Colors.red, size: 20),
                                onPressed: () => _removeDestination(index),
                              ),
                          ],
                        ),
                      );
                    }),
                    AppButton.outline(
                      text: 'Add Stop',
                      height: 40,
                      icon: const Icon(Iconsax.add, size: 18),
                      onPressed: _addDestination,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const SectionHeader(title: 'Vehicle Information'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    VehicleTypeDropdown(
                      selectedId: controller.selectedVehicleTypeId,
                      errorText: vehicleTypeError,
                      onChanged: (id, name) {
                        setState(() => vehicleTypeError = null);
                        if (id != null) controller.selectedVehicleTypeId.value = id;
                        if (name != null) controller.selectedVehicleType.value = name;
                      },
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
                        // const SizedBox(width: 8),
                        // Expanded(
                        //   child: AppInputField(
                        //     label: 'Capacity',
                        //     controller: controller.seatingCapacityController,
                        //     hint: 'e.g. 45',
                        //     keyboardType: TextInputType.number,
                        //     validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Capacity'),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              const SectionHeader(title: 'Customer Details (Optional)'),
              const SizedBox(height: 8),
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
                    const SizedBox(height: 12),
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
              
              const SizedBox(height: 16),
              const SectionHeader(title: 'Payment Details'),
              const SizedBox(height: 8),
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
                    const SizedBox(height: 12),
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
                            return AppInputField(
                              label: 'Pending',
                              hint: controller.pendingAmount.toStringAsFixed(2),
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
                onPressed: _handleSave,
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

  void _handleSave() {
    setState(() => vehicleTypeError = null);
    bool isValid = formKey.currentState!.validate();
    
    if (controller.selectedVehicleTypeId.value == null || controller.selectedVehicleTypeId.value == 0) {
      setState(() => vehicleTypeError = 'Please select vehicle type');
      isValid = false;
    }

    if (!isValid) return;

    if (_pickupPoint == null || _destinationPoints.any((p) => p == null)) {
      Get.snackbar('Error', 'Please select all locations', 
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Prepare points like in CreateLeadScreen
    final List<Map<String, dynamic>> points = [];
    points.add({
      "type": "start",
      "name": _pickupPoint!['name'],
      "lat": _pickupPoint!['lat'],
      "lng": _pickupPoint!['lng'],
      "order": 0
    });

    for (int i = 0; i < _destinationPoints.length; i++) {
      final isLast = i == _destinationPoints.length - 1;
      points.add({
        "type": isLast ? "end" : "stop",
        "name": _destinationPoints[i]!['name'],
        "lat": _destinationPoints[i]!['lat'],
        "lng": _destinationPoints[i]!['lng'],
        "order": i + 1
      });
    }

    controller.destinationPoints.assignAll(points);
    controller.routeController.text = "${_pickupPoint!['name']} to ${_destinationPoints.last!['name']}";

    // For now, just go back like the original code did on success
    Get.back();
  }

  Widget _buildDropdown(String label, RxString value, List<String> items, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
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
