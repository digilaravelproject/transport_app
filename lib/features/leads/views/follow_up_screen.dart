import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../domain/models/lead_model.dart';
import '../controllers/lead_controller.dart';

class FollowUpScreen extends GetView<LeadController> {
  const FollowUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LeadModel lead = Get.arguments ?? controller.leads.first;
    final reminderDate = DateTime.now().obs;
    final reminderTime = TimeOfDay.now().obs;
    final noteController = TextEditingController();

    return AppScaffold(
      appBar: AppHeader(
        title: 'Follow Up',
        subtitle: lead.customerName,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Set Reminder for this Lead', style: AppTextStyle.subheading, fontSize: 16),
                  const SizedBox(height: 16),
                  
                  // Date Picker
                  AppText('Reminder Date', style: AppTextStyle.label),
                  const SizedBox(height: 4),
                  _PickerTile(
                    icon: Iconsax.calendar_1,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: reminderDate.value,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) reminderDate.value = date;
                    },
                    child: Obx(() => AppText('${reminderDate.value.day}/${reminderDate.value.month}/${reminderDate.value.year}', style: AppTextStyle.body)),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Time Picker
                  AppText('Reminder Time', style: AppTextStyle.label),
                  const SizedBox(height: 4),
                  _PickerTile(
                    icon: Icons.access_time_rounded,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: reminderTime.value,
                      );
                      if (time != null) reminderTime.value = time;
                    },
                    child: Obx(() => AppText(reminderTime.value.format(context), style: AppTextStyle.body)),
                  ),

                  const SizedBox(height: 12),

                  // Note
                  AppInputField(
                    label: 'Reminder Note',
                    hint: 'e.g. Call for final confirmation',
                    maxLines: 3,
                    controller: noteController,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Obx(() => AppButton(
              text: 'Save Reminder',
              isLoading: controller.isLoading.value,
              onPressed: () async {
                if (noteController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Please enter a note', backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }

                final DateTime fullDateTime = DateTime(
                  reminderDate.value.year,
                  reminderDate.value.month,
                  reminderDate.value.day,
                  reminderTime.value.hour,
                  reminderTime.value.minute,
                );

                final String formattedDate = "${fullDateTime.year}-${fullDateTime.month.toString().padLeft(2, '0')}-${fullDateTime.day.toString().padLeft(2, '0')} ${fullDateTime.hour.toString().padLeft(2, '0')}:${fullDateTime.minute.toString().padLeft(2, '0')}:00";

                final success = await controller.addLeadFollowup(lead.id!, {
                  "reminder_at": formattedDate,
                  "note": noteController.text.trim(),
                });

                if (success) {
                  Get.back();
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final VoidCallback onTap;

  const _PickerTile({required this.icon, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryColor),
            const SizedBox(width: 12),
            child,
            const Spacer(),
            const Icon(Iconsax.arrow_right_3, size: 14, color: AppColors.textColorHint),
          ],
        ),
      ),
    );
  }
}
