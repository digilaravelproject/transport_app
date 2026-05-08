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
import '../../../core/utils/custom_snackbar.dart';

class AddDutyRecordScreen extends StatefulWidget {
  const AddDutyRecordScreen({Key? key}) : super(key: key);

  @override
  State<AddDutyRecordScreen> createState() => _AddDutyRecordScreenState();
}

class _AddDutyRecordScreenState extends State<AddDutyRecordScreen> {
  final StaffController controller = Get.find<StaffController>();
  late StaffModel staff;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _tripController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    staff = Get.arguments ?? controller.staffList.first;
    _dateController.text = _formatDate(DateTime.now());
    _selectedDate = DateTime.now();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0)) : (_endTime ?? const TimeOfDay(hour: 17, minute: 30)),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _endTime = picked;
          _endTimeController.text = picked.format(context);
        }
        _calculateHours();
      });
    }
  }

  void _calculateHours() {
    if (_startTime != null && _endTime != null) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
      var end = DateTime(now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);
      
      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }
      
      final diff = end.difference(start);
      final hours = diff.inMinutes / 60.0;
      _hoursController.text = hours.toStringAsFixed(2);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      CustomSnackbar.showError('Please pick date and times');
      return;
    }

    final success = await controller.addDutyRecord(
      staffId: staff.id,
      date: _dateController.text,
      status: 'present',
      inTime: _formatTime(_startTime!),
      outTime: _formatTime(_endTime!),
      notes: _tripController.text.isNotEmpty 
          ? '${_tripController.text}${_notesController.text.isNotEmpty ? " - ${_notesController.text}" : ""}'
          : _notesController.text,
    );

    if (success) {
      CustomSnackbar.showSuccess('Duty record saved successfully');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Add Duty Record',
        subtitle: staff.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppCard(
                child: Column(
                  children: [
                    AppInputField(
                      label: 'Duty Date',
                      hint: 'YYYY-MM-DD',
                      controller: _dateController,
                      icon: Iconsax.calendar_1,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (val) => val == null || val.isEmpty ? 'Please select a date' : null,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Trip / Purpose',
                      hint: 'e.g. Delhi to Chandigarh',
                      controller: _tripController,
                      icon: Icons.route_rounded,
                      validator: (val) => val == null || val.isEmpty ? 'Please enter trip details' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppInputField(
                            label: 'Start Time',
                            hint: '09:00 AM',
                            controller: _startTimeController,
                            icon: Icons.access_time_rounded,
                            readOnly: true,
                            onTap: () => _selectTime(context, true),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppInputField(
                            label: 'End Time',
                            hint: '06:00 PM',
                            controller: _endTimeController,
                            icon: Icons.access_time_filled_rounded,
                            readOnly: true,
                            onTap: () => _selectTime(context, false),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              if (_startTime != null && _endTime != null) {
                                if (_startTime!.hour == _endTime!.hour && _startTime!.minute == _endTime!.minute) {
                                  return 'Should be different';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Total Hours',
                      hint: '0.0',
                      controller: _hoursController,
                      icon: Icons.timer_outlined,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      label: 'Notes',
                      hint: 'Additional details...',
                      controller: _notesController,
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                text: 'Save Record',
                isLoading: controller.isLoading.value,
                onPressed: _handleSave,
              )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
