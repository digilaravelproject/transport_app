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
import '../controllers/shift_controller.dart';

class CreateShiftScreen extends StatefulWidget {
  const CreateShiftScreen({Key? key}) : super(key: key);

  @override
  State<CreateShiftScreen> createState() => _CreateShiftScreenState();
}

class _CreateShiftScreenState extends State<CreateShiftScreen> {
  final ShiftController controller = Get.find<ShiftController>();
  String _shiftType = 'Regular';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Create Shift',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Shift Details', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Shift Name',
                    hint: 'e.g. Morning Shift A',
                    icon: Icons.access_time_filled_rounded,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: const AppInputField(
                          label: 'Start Time',
                          hint: '06:00 AM',
                          icon: Icons.timer_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: const AppInputField(
                          label: 'End Time',
                          hint: '02:00 PM',
                          icon: Icons.timer_off_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown('Shift Type', _shiftType, ['Regular', 'Overtime', 'Special Duty'], (val) => setState(() => _shiftType = val!)),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Date',
                    hint: 'DD/MM/YYYY',
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Notes / Instructions',
                    hint: 'Add details...',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Shift Segment',
              onPressed: () {
                Get.snackbar('Success', 'Shift segment created.', snackPosition: SnackPosition.BOTTOM);
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Cancel',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label),
        const SizedBox(height: 8),
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
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}
