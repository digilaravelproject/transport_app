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
import '../../../routes/route_helper.dart';
import '../../../core/utils/phone_helper.dart';
import '../controllers/lead_controller.dart';

class CreateLeadScreen extends GetView<LeadController> {
  const CreateLeadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Create Lead',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Trip Details ─────────────────────────────────────────
            const SectionHeader(title: 'Trip Details'),
            const SizedBox(height: 8),
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
            ),
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
                        child: _DropdownField(
                          label: 'Vehicle Type',
                          value: controller.selectedVehicleType,
                          items: const ['Sedan (4 Seater)', 'SUV (7 Seater)', 'Innova (7 Seater)', 'Tempo Traveller (12 Seater)', 'Mini Bus (25 Seater)', 'Luxury Bus (45 Seater)'],
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    label: 'Pickup Address',
                    hint: 'Enter pickup point',
                    icon: Iconsax.location,
                    controller: controller.pickupAddressController,
                  ),
                  const SizedBox(height: 12),
                  _DestinationsList(),
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
                  ),
                  const SizedBox(height: 20),
                    Obx(() => AppInputField(
                      label: 'Mobile Number',
                      hint: 'Enter 10 digit number',
                      keyboardType: TextInputType.phone,
                      controller: controller.phoneController,
                      icon: Iconsax.call,
                      phoneCode: controller.selectedCountryCode.value,
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
            AppButton(
              text: 'Save Lead',
              onPressed: () => controller.addLead(),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Generate Quotation',
              onPressed: () => Get.toNamed(RouteHelper.getQuotationPreviewRoute()),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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

class _DestinationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadController>();
    return Column(
      children: [
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.destinationPoints.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      '• ${controller.destinationPoints[index]}',
                      style: AppTextStyle.body,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                    onPressed: () => controller.removeDestination(index),
                  ),
                ],
              ),
            );
          },
        )),
        TextButton.icon(
          onPressed: () => _addDestinationDialog(context, controller),
          icon: const Icon(Iconsax.add, size: 20),
          label: const AppText('Add Destination Point', color: AppColors.primaryColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _addDestinationDialog(BuildContext context, LeadController controller) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const AppText('Add Destination', style: AppTextStyle.subheading),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'e.g. Rohtang Pass'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.addDestination(textController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
