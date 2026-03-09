import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/models/staff_model.dart';

class AddDutyRecordScreen extends StatefulWidget {
  const AddDutyRecordScreen({Key? key}) : super(key: key);

  @override
  State<AddDutyRecordScreen> createState() => _AddDutyRecordScreenState();
}

class _AddDutyRecordScreenState extends State<AddDutyRecordScreen> {
  final StaffModel staff = Get.arguments ?? Get.find<StaffController>().staffList.first;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Add Duty Record',
        subtitle: staff.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  const AppInputField(
                    label: 'Duty Date',
                    hint: 'DD/MM/YYYY',
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Trip / Purpose',
                    hint: 'e.g. Delhi to Chandigarh',
                    icon: Icons.route_rounded,
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: AppInputField(
                          label: 'Start Time',
                          hint: '09:00 AM',
                          icon: Icons.access_time_rounded,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: AppInputField(
                          label: 'End Time',
                          hint: '06:00 PM',
                          icon: Icons.access_time_filled_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Total Hours',
                    hint: '9.0',
                    icon: Icons.timer_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Notes',
                    hint: 'Additional details...',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Record',
              onPressed: () => Get.back(),
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
}
