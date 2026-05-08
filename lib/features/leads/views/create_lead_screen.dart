import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_validators.dart';
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
import '../domain/models/lead_model.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({Key? key}) : super(key: key);

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final LeadController controller = Get.find<LeadController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LeadModel? _editLead;
  bool get _isEdit => _editLead != null;

  Map<String, dynamic>? _pickupPoint;
  final List<TextEditingController> _destinationControllers = [];
  final List<Map<String, dynamic>?> _destinationPoints = [];
  late TextEditingController _vehicleCountController;

  String? vehicleTypeError;

  @override
  void initState() {
    super.initState();
    _editLead = Get.arguments is LeadModel ? Get.arguments as LeadModel : null;
    _vehicleCountController = TextEditingController();
    
    if (_isEdit) {
      _prefillData();
    } else {
      controller.resetForm();
      _destinationControllers.add(TextEditingController());
      _destinationPoints.add(null);
      _vehicleCountController.text = controller.vehicleCount.value.toString();
    }
  }

  void _prefillData() {
    final lead = _editLead!;
    controller.customerNameController.text = lead.customerName;
    
    // Split phone and country code
    String phone = lead.phone.replaceAll(' ', '');
    if (phone.startsWith('+91')) {
      controller.selectedCountryCode.value = '+91';
      phone = phone.substring(3);
    } else if (phone.startsWith('91') && phone.length > 10) {
      controller.selectedCountryCode.value = '+91';
      phone = phone.substring(2);
    } else if (phone.startsWith('+')) {
      if (phone.length > 10) {
        int splitIndex = phone.length - 10;
        controller.selectedCountryCode.value = phone.substring(0, splitIndex);
        phone = phone.substring(splitIndex);
      }
    }
    controller.phoneController.text = phone;
    controller.routeController.text = lead.route;
    controller.totalAmountController.text = lead.totalAmount.toString();
    controller.advancePaymentController.text = lead.advancePayment.toString();
    controller.selectedDate.value = lead.date;
    controller.selectedDuration.value = lead.duration;
    controller.selectedVehicleType.value = lead.vehicleType;
    controller.selectedVehicleTypeId.value = lead.vehicleTypeId;
    controller.vehicleCount.value = lead.vehicleCount;
    _vehicleCountController.text = lead.vehicleCount.toString();
    controller.pickupAddressController.text = lead.pickupAddress ?? '';
    
    if (lead.rawPoints != null && lead.rawPoints!.isNotEmpty) {
      final points = lead.rawPoints!;
      final startPoint = points.firstWhere((p) => p['type'] == 'start', orElse: () => points.first);
      _pickupPoint = {
        'name': startPoint['name'],
        'lat': startPoint['lat'],
        'lng': startPoint['lng'],
      };
      controller.pickupAddressController.text = startPoint['name'];

      final destinations = points.where((p) => p['type'] != 'start').toList();
      destinations.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));

      if (destinations.isEmpty) {
        _destinationControllers.add(TextEditingController());
        _destinationPoints.add(null);
      } else {
        for (var p in destinations) {
          _destinationControllers.add(TextEditingController(text: p['name']));
          _destinationPoints.add({
            'name': p['name'],
            'lat': p['lat'],
            'lng': p['lng'],
          });
        }
      }
    } else {
      _destinationControllers.add(TextEditingController());
      _destinationPoints.add(null);
    }
  }

  @override
  void dispose() {
    for (var c in _destinationControllers) {
      c.dispose();
    }
    _vehicleCountController.dispose();
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
      appBar: AppHeader(
        title: _isEdit ? 'Edit Lead' : 'Create Lead',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SectionHeader(title: 'Trip Details'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(12),
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
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) controller.selectedDate.value = date;
                            },
                            value: controller.selectedDate,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DropdownField(
                            label: 'Duration',
                            value: controller.selectedDuration,
                            items: const ['1 Day', '2 Days', '3 Days', '5 Days', '1 Week', 'Custom'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                    AppInputField(
                      label: 'Vehicle Count',
                      hint: 'Enter number of vehicles',
                      icon: Iconsax.bus,
                      keyboardType: TextInputType.number,
                      controller: _vehicleCountController,
                      onChanged: (val) => controller.vehicleCount.value = int.tryParse(val) ?? 1,
                      validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Count'),
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
                      icon: Icon(Iconsax.add, size: 18),
                      onPressed: _addDestination,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const SectionHeader(title: 'Customer Info'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppInputField(
                      label: 'Customer Name',
                      hint: 'Enter full name',
                      icon: Iconsax.user,
                      controller: controller.customerNameController,
                      validator: (val) => AppValidators.validateEmpty(val, fieldName: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => AppInputField(
                      label: 'Contact Number',
                      hint: '10-digit mobile number',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                      controller: controller.phoneController,
                      phoneCode: controller.selectedCountryCode.value,
                      onPhoneCodeTap: () => PhoneHelper.showCountryPicker(
                        context: context,
                        selectedCode: controller.selectedCountryCode,
                      ),
                      validator: (val) => AppValidators.validateMobile(val),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const SectionHeader(title: 'Financials'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(12),
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
                            validator: (val) => AppValidators.validateEmpty(val, fieldName: 'Total'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppInputField(
                            label: 'Advance',
                            hint: '0.00',
                            icon: Iconsax.empty_wallet,
                            keyboardType: TextInputType.number,
                            controller: controller.advancePaymentController,
                            validator: (val) => AppValidators.validateEmpty(val, fieldName: 'Advance'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

              const SizedBox(height: 24),
              Obx(() => AppButton(
                text: _isEdit ? 'Update Lead' : 'Save Lead',
                isLoading: controller.isLoading.value,
                onPressed: () => _handleSubmit(),
              )),
              const SizedBox(height: 8),
              if (!_isEdit)
                AppButton.outline(
                  text: 'Generate Quotation',
                  onPressed: () => Get.toNamed(RouteHelper.getQuotationPreviewRoute()),
                )
              else
                AppButton.outline(
                  text: 'Delete Lead',
                  color: Colors.red,
                  onPressed: () => _showDeleteConfirmation(),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.trash, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 24),
              const AppText('Delete Lead', style: AppTextStyle.subheading, fontSize: 20),
              const SizedBox(height: 12),
              AppText(
                'Are you sure you want to delete this lead? This action cannot be undone and will remove all related data.',
                style: AppTextStyle.body,
                color: AppColors.textColorSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Delete',
                      color: Colors.red,
                      onPressed: () async {
                        Get.back();
                        final success = await controller.deleteLead(_editLead!.id!);
                        if (success) {
                          Get.offAllNamed(RouteHelper.getLeadListRoute());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    setState(() => vehicleTypeError = null);

    bool isValid = _formKey.currentState!.validate();

    if (controller.selectedVehicleTypeId.value == null || controller.selectedVehicleTypeId.value == 0) {
      setState(() => vehicleTypeError = 'Vehicle Type is required');
      isValid = false;
    }

    if (!isValid) return;

    if (_pickupPoint == null || _destinationPoints.any((p) => p == null)) {
      Get.snackbar('Error', 'Please select all locations', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

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

    int durationDays = 1;
    String durationText = controller.selectedDuration.value;
    if (durationText.contains('Day')) {
      durationDays = int.tryParse(durationText.split(' ')[0]) ?? 1;
    } else if (durationText.contains('Week')) {
      durationDays = 7;
    } else {
      durationDays = int.tryParse(durationText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    }

    controller.destinationPoints.assignAll(points);

    if (_isEdit) {
      final success = await controller.updateLead(_editLead!.id!);
      if (success) {
        Get.back();
      }
    } else {
      final payload = {
        "trip_route": "${_pickupPoint!['name']} to ${_destinationPoints.last!['name']}",
        "trip_date": controller.selectedDate.value.toIso8601String().split('T')[0],
        "duration_days": durationDays,
        "vehicle_type": controller.selectedVehicleTypeId.value ?? 1,
        "seating_capacity": controller.vehicleCount.value,
        "pickup_address": controller.pickupAddressController.text,
        "points": points,
        "customer_name": controller.customerNameController.text.trim(),
        "customer_contact": "${controller.selectedCountryCode.value}${controller.phoneController.text.trim()}",
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
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Obx(() => AppText(
                  '${value.value.day}/${value.value.month}/${value.value.year}',
                  style: AppTextStyle.body,
                  fontSize: 13,
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
        const SizedBox(height: 6),
        Obx(() {
          final currentValue = value.value;
          final valueExistsInItems = items.contains(currentValue);
          
          if (!valueExistsInItems && currentValue.isNotEmpty && currentValue != 'Custom') {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(currentValue, style: AppTextStyle.body, fontSize: 13),
                  InkWell(
                    onTap: () => value.value = 'Custom',
                    child: const Icon(Icons.edit, size: 16, color: AppColors.primaryColor),
                  ),
                ],
              ),
            );
          }
          
          return Container(
            height: 48,
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
                    child: AppText(item, style: AppTextStyle.body, fontSize: 13),
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
