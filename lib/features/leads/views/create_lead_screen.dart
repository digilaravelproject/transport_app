import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/vehicle_type_dropdown.dart';
import '../../../routes/route_helper.dart';
import '../../../core/utils/phone_helper.dart';
import '../controllers/lead_controller.dart';
import '../../routes_management/views/location_search_screen.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({Key? key}) : super(key: key);

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final LeadController controller = Get.find<LeadController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _pickupPoint;
  final List<TextEditingController> _destinationControllers = [TextEditingController()];
  final List<Map<String, dynamic>?> _destinationPoints = [null];

  @override
  void initState() {
    super.initState();
    controller.resetForm();
  }

  @override
  void dispose() {
    for (var c in _destinationControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Create Lead',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // ── Trip Details ─────────────────────────────────────────
              const SectionHeader(title: 'Trip Details'),
              /*const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.tripPresets.length,
                  itemBuilder: (context, index) {
                    final preset = controller.tripPresets[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        label: AppText(
                          preset['label'],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                        side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () => controller.applyPreset(index),
                      ),
                    );
                  },
                ),
              ),*/
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerField(
                            label: 'Trip Date',
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: controller.selectedDate.value,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) controller.selectedDate.value = date;
                            },
                            value: controller.selectedDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Duration',
                            value: controller.selectedDuration,
                            items: const ['1 Day', '2 Days', '3 Days', '5 Days', '1 Week', 'Custom'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: VehicleTypeDropdown(
                            selectedId: controller.selectedVehicleTypeId,
                            onChanged: (id, displayName) {
                              controller.selectedVehicleType.value = displayName;
                              controller.selectedVehicleTypeId.value = id;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: AppInputField(
                            label: 'Vehicle Count',
                            hint: '1',
                            icon: Icons.filter_9_plus_rounded,
                            iconSize: 16,
                            keyboardType: TextInputType.number,
                            onChanged: (v) => controller.vehicleCount.value = int.tryParse(v) ?? 1,
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Pickup Address (Start Point)
                    AppInputField(
                      label: 'Pickup Address (Start)',
                      hint: 'Search pickup location',
                      icon: Iconsax.location5,
                      controller: controller.pickupAddressController,
                      readOnly: true,
                      isRequired: true,
                      validator: (val) => (val == null || val.isEmpty) ? 'Please select pickup point' : null,
                      onTap: () async {
                        final result = await Get.to(() => const LocationSearchScreen(title: 'Search Pickup Point'));
                        if (result != null) {
                          setState(() {
                            _pickupPoint = result;
                            controller.pickupAddressController.text = result['name'];
                          });
                          controller.calculateRoute();
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Destinations (Multiple Points)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Destinations',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorPrimary,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _destinationControllers.add(TextEditingController());
                              _destinationPoints.add(null);
                            });
                          },
                          child: const Row(
                            children: [
                              Icon(Iconsax.add, size: 18, color: AppColors.primaryColor),
                              SizedBox(width: 4),
                              AppText('Add Destination',
                                fontSize: 13,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_destinationControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppInputField(
                                hint: index == 0 ? 'e.g. Dadar, Mumbai' : 'Enter destination...',
                                icon: Iconsax.location,
                                controller: _destinationControllers[index],
                                readOnly: true,
                                isRequired: true,
                                validator: (val) => (val == null || val.isEmpty) ? 'Please select a destination' : null,
                                onTap: () async {
                                  final result = await Get.to(() => LocationSearchScreen(title: 'Search Destination ${index + 1}'));
                                  if (result != null) {
                                    setState(() {
                                      _destinationPoints[index] = result;
                                      _destinationControllers[index].text = result['name'];
                                      // If it's the last destination, set it as the primary destination for calculation
                                      if (index == _destinationControllers.length - 1) {
                                        controller.destinationController.text = result['name'];
                                      }
                                    });
                                    controller.calculateRoute();
                                  }
                                },
                              ),
                            ),
                            if (_destinationControllers.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.errorColor, size: 22),
                                  onPressed: () {
                                    setState(() {
                                      _destinationControllers[index].dispose();
                                      _destinationControllers.removeAt(index);
                                      _destinationPoints.removeAt(index);
                                    });
                                    controller.calculateRoute();
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const SectionHeader(title: 'Customer Details'),
              const SizedBox(height: 6),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AppInputField(
                      label: 'Customer Name',
                      hint: 'Enter full name',
                      icon: Iconsax.user,
                      controller: controller.customerNameController,
                      isRequired: true,
                      validator: (val) => (val == null || val.isEmpty) ? 'Please enter customer name' : null,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => AppInputField(
                      label: 'Mobile Number',
                      hint: 'Enter 10 digit number',
                      keyboardType: TextInputType.phone,
                      controller: controller.phoneController,
                      icon: Iconsax.call,
                      phoneCode: controller.selectedCountryCode.value,
                      isRequired: true,
                      validator: (val) => (val == null || val.isEmpty) ? 'Please enter mobile number' : null,
                      onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                        context: context,
                        selectedCode: controller.selectedCountryCode,
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Payment Details ──────────────────────────────────────
              const SectionHeader(title: 'Payment Details'),
              const SizedBox(height: 6),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppInputField(
                            label: 'Total Amount',
                            hint: '0.00',
                            icon: Iconsax.card,
                            keyboardType: TextInputType.number,
                            controller: controller.totalAmountController,
                            isRequired: true,
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppInputField(
                            label: 'Advance',
                            hint: '0.00',
                            icon: Iconsax.empty_wallet,
                            keyboardType: TextInputType.number,
                            controller: controller.advancePaymentController,
                            isRequired: true,
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText('Pending Amount', style: AppTextStyle.body, fontWeight: FontWeight.w600),
                          ValueListenableBuilder(
                            valueListenable: controller.totalAmountController,
                            builder: (context, totalValue, child) {
                              return ValueListenableBuilder(
                                valueListenable: controller.advancePaymentController,
                                builder: (context, advanceValue, child) {
                                  return AppText(
                                    '₹ ${controller.pendingAmount}',
                                    style: AppTextStyle.subheading,
                                    color: AppColors.primaryColor,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Action Buttons ───────────────────────────────────────
              Obx(() => AppButton(
                text: 'Save Lead',
                isLoading: controller.isLoading.value,
                onPressed: () => _handleSubmit(),
              )),
              const SizedBox(height: 12),
              AppButton.outline(
                text: 'Generate Quotation',
                onPressed: () => Get.toNamed(RouteHelper.getQuotationPreviewRoute()),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickupPoint == null || _destinationPoints.any((p) => p == null)) {
      Get.snackbar('Error', 'Please select all locations', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (controller.selectedVehicleTypeId.value == null) {
      Get.snackbar('Error', 'Please select a vehicle type', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Build points list
    final List<Map<String, dynamic>> points = [];
    
    // 1. Start point (Pickup)
    points.add({
      "type": "start",
      "name": _pickupPoint!['name'],
      "lat": _pickupPoint!['lat'],
      "lng": _pickupPoint!['lng'],
      "order": 0
    });

    // 2. Intermediate and End points
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

    // Extract duration days as int
    int durationDays = 1;
    String durationText = controller.selectedDuration.value;
    if (durationText.contains('Day')) {
      durationDays = int.tryParse(durationText.split(' ')[0]) ?? 1;
    } else if (durationText.contains('Week')) {
      durationDays = 7;
    } else {
      durationDays = int.tryParse(durationText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    }

    final payload = {
      "trip_route": "Lucknow to Delhi",
      "trip_date": controller.selectedDate.value.toIso8601String().split('T')[0],
      "duration_days": durationDays,
      "vehicle_type": controller.selectedVehicleTypeId.value,
      "seating_capacity": controller.vehicleCount.value, // User said vehicle count goes here
      "pickup_address": controller.pickupAddressController.text,
      "points": points,
      "customer_name": controller.customerNameController.text.trim(),
      "customer_contact": controller.phoneController.text.trim(),
      "total_amount": double.tryParse(controller.totalAmountController.text) ?? 0,
      "advance_amount": double.tryParse(controller.advancePaymentController.text) ?? 0,
      "pending_amount": controller.pendingAmount,
    };

    final success = await controller.createLead(payload);
    if (success) {
      Get.back();
    }
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Rx<DateTime> value;

  const _DatePickerField({required this.label, required this.onTap, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1, size: 18, color: AppColors.primaryColor),
                const SizedBox(width: 10),
                Obx(() => AppText(
                  '${value.value.day}/${value.value.month}/${value.value.year}',
                  style: AppTextStyle.body,
                  fontSize: 14,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final RxString value;
  final List<String> items;

  const _DropdownField({required this.label, required this.value, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label),
        const SizedBox(height: 8),
        Obx(() {
          final currentValue = value.value;
          final valueExistsInItems = items.contains(currentValue);
          
          if (!valueExistsInItems && currentValue.isNotEmpty && currentValue != 'Custom') {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(currentValue, style: AppTextStyle.body, fontSize: 14),
                  InkWell(
                    onTap: () => value.value = 'Custom',
                    child: const Icon(Icons.edit, size: 18, color: AppColors.primaryColor),
                  ),
                ],
              ),
            );
          }
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: valueExistsInItems ? currentValue : items.first,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: (v) async {
                  if (v != null) {
                    if (v == 'Custom' && label == 'Duration') {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => _CustomDurationDialog(),
                      );
                      if (result != null && result.isNotEmpty) {
                        value.value = result;
                      }
                    } else {
                      value.value = v;
                    }
                  }
                },
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: AppText(item, style: AppTextStyle.body, fontSize: 14),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _CustomDurationDialog extends StatefulWidget {
  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppText('Custom Duration', style: AppTextStyle.subheading),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'e.g., 10 Days',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.of(context).pop(_controller.text);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
