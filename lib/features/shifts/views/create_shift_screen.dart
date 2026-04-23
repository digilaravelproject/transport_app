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
import '../../../core/utils/custom_snackbar.dart';
import '../controllers/shift_controller.dart';

class CreateShiftScreen extends StatefulWidget {
  const CreateShiftScreen({Key? key}) : super(key: key);

  @override
  State<CreateShiftScreen> createState() => _CreateShiftScreenState();
}

class _CreateShiftScreenState extends State<CreateShiftScreen> {
  final ShiftController controller = Get.find<ShiftController>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String _shiftType = 'Regular';

  @override
  void dispose() {
    _nameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Display format: DD/MM/YYYY
        _dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _createShift() async {
    if (_nameController.text.isEmpty) {
      CustomSnackbar.showError('Please enter shift name');
      return;
    }
    if (_startTimeController.text.isEmpty) {
      CustomSnackbar.showError('Please select start time');
      return;
    }
    if (_endTimeController.text.isEmpty) {
      CustomSnackbar.showError('Please select end time');
      return;
    }

    // Convert time format from "06:00 AM" to "06:00"
    String startTime = _convertTimeFormat(_startTimeController.text);
    String endTime = _convertTimeFormat(_endTimeController.text);
    
    // Convert date format from "DD/MM/YYYY" to "YYYY-MM-DD"
    String? date;
    if (_dateController.text.isNotEmpty) {
      date = _convertDateFormat(_dateController.text);
    }

    await controller.createShift(
      name: _nameController.text,
      startTime: startTime,
      endTime: endTime,
      type: _shiftType,
      date: date,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    // Check if creation was successful
    if (controller.isSuccess.value) {
      // Wait a bit for the snackbar to show, then navigate back
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    }
  }

  String _convertTimeFormat(String time) {
    // Convert "06:00 AM" to "06:00" or "02:00 PM" to "14:00"
    try {
      final TimeOfDay timeOfDay = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1].split(' ')[0]),
      );
      return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  String _convertDateFormat(String date) {
    // Convert "DD/MM/YYYY" to "YYYY-MM-DD"
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = parts[0];
        final month = parts[1];
        final year = parts[2];
        return '$year-$month-$day';
      }
      return date;
    } catch (e) {
      return date;
    }
  }

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
                  AppInputField(
                    label: 'Shift Name',
                    hint: 'e.g. Morning Shift A',
                    icon: Icons.access_time_filled_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectStartTime,
                          child: AppInputField(
                            label: 'Start Time',
                            hint: '06:00 AM',
                            icon: Icons.timer_outlined,
                            controller: _startTimeController,
                            readOnly: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectEndTime,
                          child: AppInputField(
                            label: 'End Time',
                            hint: '02:00 PM',
                            icon: Icons.timer_off_outlined,
                            controller: _endTimeController,
                            readOnly: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown('Shift Type', _shiftType, ['Regular', 'Overtime', 'Special Duty'], (val) => setState(() => _shiftType = val!)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AppInputField(
                      label: 'Date',
                      hint: 'DD/MM/YYYY',
                      icon: Iconsax.calendar_1,
                      controller: _dateController,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Notes / Instructions',
                    hint: 'Add details...',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                    controller: _notesController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Obx(() => AppButton(
              text: controller.isLoading.value ? 'Creating...' : 'Save Shift Segment',
              onPressed: controller.isLoading.value ? null : _createShift,
            )),
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
