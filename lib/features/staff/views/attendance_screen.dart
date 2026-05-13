import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/attendance_controller.dart';
import '../domain/models/attendance_model.dart';
import '../../../routes/route_helper.dart';

class AttendanceScreen extends GetView<AttendanceController> {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.attendanceManagement.tr,
        trailing: Obx(() => controller.isToday() 
          ? IconButton(
              icon: const Icon(Iconsax.clock),
              onPressed: () => Get.toNamed(RouteHelper.getAttendanceHistoryRoute()),
            )
          : TextButton(
              onPressed: () => controller.changeDate(DateTime.now()),
              child: AppText(AppTextConstants.today.tr, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
            )),
      ),
      body: Column(
        children: [
          Obx(() => _buildDatePicker()),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (controller.attendanceList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.user,
                        size: 64,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        AppTextConstants.noStaffFoundDate.tr,
                        style: AppTextStyle.body,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 16),

                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshAttendance(),
                color: AppColors.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.attendanceList.length,
                  itemBuilder: (context, index) {
                    final staff = controller.attendanceList[index];
                    return _StaffAttendanceRow(staff: staff);
                  },
                ),
              );
            }),
          ),
          Obx(() {
            if (controller.attendanceList.isEmpty || controller.isLoading.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: AppButton(
                text: AppTextConstants.saveAttendance.tr,
                isLoading: controller.isLoading.value,
                onPressed: () => controller.saveAttendance(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primaryColor),
            onPressed: () => controller.changeDate(controller.selectedDate.value.subtract(const Duration(days: 1))),
          ),
          Row(
            children: [
              const Icon(Iconsax.calendar_1, size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 12),
              AppText(
                controller.isToday() ? '${AppTextConstants.today.tr}, ${_getFormattedDate(controller.selectedDate.value)}' : _getFormattedDate(controller.selectedDate.value),
                style: AppTextStyle.subheading,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryColor),
            onPressed: () => controller.changeDate(controller.selectedDate.value.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      AppTextConstants.jan.tr, AppTextConstants.feb.tr, AppTextConstants.mar.tr, 
      AppTextConstants.apr.tr, AppTextConstants.may.tr, AppTextConstants.jun.tr, 
      AppTextConstants.jul.tr, AppTextConstants.aug.tr, AppTextConstants.sep.tr, 
      AppTextConstants.oct.tr, AppTextConstants.nov.tr, AppTextConstants.dec.tr
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}

class _StaffAttendanceRow extends GetView<AttendanceController> {
  final AttendanceModel staff;
  const _StaffAttendanceRow({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentStatus = controller.dailyAttendance[staff.id] ?? '';
      
      return AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: AppText(
                    staff.name.isNotEmpty
                        ? staff.name[0].toUpperCase()
                        : '?',
                    style: AppTextStyle.body,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                // CircleAvatar(
                //   radius: 24,
                //   backgroundColor: AppColors.primaryLight,
                //   child: const Icon(Iconsax.user, size: 26, color: AppColors.primaryColor),
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(staff.name, style: AppTextStyle.subheading, fontSize: 16, fontWeight: FontWeight.bold),
                      AppText(staff.staffType, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                      // if (staff.attendance != null && staff.attendance!.inTime != null)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 4),
                      //     child: Row(
                      //       children: [
                      //         const Icon(Iconsax.clock, size: 12, color: AppColors.textColorSecondary),
                      //         const SizedBox(width: 4),
                      //         AppText(
                      //           'In: ${staff.attendance!.inTime} ${staff.attendance!.outTime != null ? "• Out: ${staff.attendance!.outTime}" : ""}',
                      //           style: AppTextStyle.caption,
                      //           fontSize: 11,
                      //           color: AppColors.textColorSecondary,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ],
                  ),
                ),
                _StatusIndicator(status: currentStatus),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildToggleOption(context, AppTextConstants.present.tr, Colors.green, currentStatus, 'Present'),
                const SizedBox(width: 8),
                _buildToggleOption(context, AppTextConstants.absent.tr, Colors.red, currentStatus, 'Absent'),
                const SizedBox(width: 8),
                _buildToggleOption(context, AppTextConstants.halfDay.tr, Colors.orange, currentStatus, 'Half Day'),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildToggleOption(BuildContext context, String label, Color color, String currentStatus, String value) {
    bool isSelected = currentStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (isSelected) return;
          
          bool shouldUpdate = true;
          if (!controller.isToday()) {
            shouldUpdate = await _showEditConfirmation(context, label);
          }
          
          if (shouldUpdate) {
            controller.updateAttendance(staff.id, value);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.slate50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : AppColors.slate200),
            boxShadow: isSelected ? [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          child: AppText(
            label,
            align: TextAlign.center,
            style: AppTextStyle.body,
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textColorSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<bool> _showEditConfirmation(BuildContext context, String newStatus) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Iconsax.warning_2, color: Colors.orange),
            const SizedBox(width: 12),
            AppText(AppTextConstants.editPastRecord.tr, style: AppTextStyle.heading, fontSize: 18),
          ],
        ),
        content: AppText(
          AppTextConstants.editPastRecordConfirmation.tr,
          style: AppTextStyle.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: AppText(AppTextConstants.cancel.tr, color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: AppText(AppTextConstants.update.tr, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _StatusIndicator extends StatelessWidget {
  final String status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: AppText(AppTextConstants.notMarked.tr, style: AppTextStyle.caption, color: AppColors.textColorSecondary, fontWeight: FontWeight.bold),
      );
    }

    Color color;
    String label = status;
    switch (status) {
      case 'Present': 
        color = Colors.green; 
        label = AppTextConstants.present.tr;
        break;
      case 'Absent': 
        color = Colors.red; 
        label = AppTextConstants.absent.tr;
        break;
      case 'Half Day': 
        color = Colors.orange; 
        label = AppTextConstants.halfDay.tr;
        break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: AppText(label, style: AppTextStyle.caption, color: color, fontWeight: FontWeight.bold),
    );
  }
}
