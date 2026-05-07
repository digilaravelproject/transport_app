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
import '../controllers/lead_controller.dart';
import '../domain/models/lead_model.dart';

class EditLeadScreen extends GetView<LeadController> {
  const EditLeadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LeadModel lead = Get.arguments;
    
    // Prefill controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.customerNameController.text = lead.customerName;
      controller.phoneController.text = lead.phone;
      controller.routeController.text = lead.route;
      controller.totalAmountController.text = lead.totalAmount.toString();
      controller.advancePaymentController.text = lead.advancePayment.toString();
      controller.selectedDate.value = lead.date;
      controller.selectedDuration.value = lead.duration;
      controller.selectedVehicleType.value = lead.vehicleType;
      controller.vehicleCount.value = lead.vehicleCount;
      controller.pickupAddressController.text = lead.pickupAddress ?? '';
    });

    return AppScaffold(
      appBar: AppHeader(
        title: 'Edit Lead',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SectionHeader(title: 'Trip Details'),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(20),
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
                  AppInputField(
                    label: 'Trip Route',
                    hint: 'e.g. Delhi to Manali',
                    icon: Icons.route_rounded,
                    controller: controller.routeController,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _DropdownField(
                          label: 'Vehicle Type',
                          value: controller.selectedVehicleType,
                          items: const ['Sedan', 'SUV', 'Innova', 'Tempo Traveller', 'Mini Bus', 'Luxury Bus'],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInputField(
                          label: 'Count',
                          hint: '1',
                          icon: Icons.filter_9_plus_rounded,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => controller.vehicleCount.value = int.tryParse(v) ?? 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const SectionHeader(title: 'Customer Details'),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppInputField(
                    label: 'Customer Name',
                    hint: 'Enter full name',
                    icon: Iconsax.user,
                    controller: controller.customerNameController,
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    label: 'Mobile Number',
                    hint: 'Enter 10 digit number',
                    icon: Iconsax.call,
                    keyboardType: TextInputType.phone,
                    controller: controller.phoneController,
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    label: 'Pickup Address',
                    hint: 'Enter pickup point',
                    icon: Iconsax.location,
                    controller: controller.pickupAddressController,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const SectionHeader(title: 'Payment Details'),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(20),
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            AppButton(
              text: 'Update Lead',
            //  onPressed: () => controller.updateLead(lead.id!),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Delete Lead',
              color: Colors.red,
              onPressed: () => _showDeleteConfirmation(context, lead.id!),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String leadId) {
    Get.defaultDialog(
      title: 'Delete Lead',
      middleText: 'Are you sure you want to delete this lead? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // close dialog
      //  controller.deleteLead(leadId);
        Get.back(); // close edit screen
      },
    );
  }
}

// ── Shared Private Widgets ─────────────────────────────────────
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
                Obx(() => AppText('${value.value.day}/${value.value.month}/${value.value.year}', style: AppTextStyle.body, fontSize: 14)),
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
          // Check if current value exists in items, if not show it as text
          final currentValue = value.value;
          final valueExistsInItems = items.contains(currentValue);
          
          if (!valueExistsInItems && currentValue.isNotEmpty && currentValue != 'Custom') {
            // Show custom value as text field
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
                      // Show custom date range picker
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
                items: items.map((String item) => DropdownMenuItem<String>(value: item, child: AppText(item, style: AppTextStyle.body, fontSize: 14))).toList(),
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
