import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';
import '../../../routes/route_helper.dart';

class AttendanceScreen extends GetView<StaffController> {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Attendance Management',
        trailing: IconButton(
          icon: const Icon(Iconsax.clock),
          onPressed: () => Get.toNamed(RouteHelper.getAttendanceHistoryRoute()),
        ),
      ),
      body: Column(
        children: [
          _buildDatePicker(),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.staffList.length,
                itemBuilder: (context, index) {
                  final staff = controller.staffList[index];
                  return _StaffAttendanceRow(staff: staff);
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              text: 'Save Attendance',
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const Icon(Iconsax.calendar_1, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          AppText(
            'Today, 06 Mar 2024',
            style: AppTextStyle.subheading,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StaffAttendanceRow extends StatefulWidget {
  final StaffModel staff;
  const _StaffAttendanceRow({required this.staff});

  @override
  State<_StaffAttendanceRow> createState() => _StaffAttendanceRowState();
}

class _StaffAttendanceRowState extends State<_StaffAttendanceRow> {
  String status = 'Present';

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Iconsax.user, size: 22, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(widget.staff.name, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                    AppText(widget.staff.role.name.capitalizeFirst!, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToggleOption('Present', Colors.green),
              const SizedBox(width: 8),
              _buildToggleOption('Absent', Colors.red),
              const SizedBox(width: 8),
              _buildToggleOption('Half Day', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, Color color) {
    bool isSelected = status == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => status = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.slate100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : AppColors.slate200),
          ),
          child: AppText(
            label,
            align: TextAlign.center,
            style: AppTextStyle.caption,
            color: isSelected ? Colors.white : AppColors.textColorSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
