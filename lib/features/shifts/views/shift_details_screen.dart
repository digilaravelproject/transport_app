import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/shift_controller.dart';
import '../domain/models/shift_model.dart';
import '../../../routes/route_helper.dart';

class ShiftDetailsScreen extends GetView<ShiftController> {
  const ShiftDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null && controller.shifts.isEmpty) {
        return const AppScaffold(appBar: AppHeader(title: 'Shift Details'), body: Center(child: Text("No shift selected")));
    }
    final ShiftModel shift = Get.arguments ?? controller.shifts.first;
    bool isUnassigned = shift.assignedDrivers.isEmpty;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Shift Details',
        rightWidget: IconButton(
          icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
          onPressed: () {},
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AppButton(
            text: 'Assign Drivers',
            onPressed: () => Get.toNamed(RouteHelper.getAssignDriverToShiftRoute()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time_filled_rounded,
                      color: AppColors.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppText(shift.shiftName, style: AppTextStyle.heading, fontSize: 24),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: shift.type == 'Overtime' ? AppColors.errorColor.withOpacity(0.1) : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(shift.type, style: AppTextStyle.caption, color: shift.type == 'Overtime' ? AppColors.errorColor : AppColors.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Shift Information', style: AppTextStyle.subheading),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildDetailRow('Start Time', shift.startTime),
                  _buildDetailRow('End Time', shift.endTime),
                  _buildDetailRow('Date', '${shift.date.day}/${shift.date.month}/${shift.date.year}'),
                  if (shift.notes != null) _buildDetailRow('Notes', shift.notes!),
                ],
              ),
            ),
             const SizedBox(height: 24),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 AppText('Assigned Drivers', style: AppTextStyle.subheading),
                 if (!isUnassigned)
                  AppText('${shift.assignedDrivers.length}', style: AppTextStyle.body, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ],
            ),
            const SizedBox(height: 12),
            if (isUnassigned) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorColor.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.group_off_outlined, color: AppColors.errorColor, size: 32),
                    const SizedBox(height: 8),
                    AppText('No drivers currently assigned to this shift.', style: AppTextStyle.caption, color: AppColors.errorColor, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ] else ...[
               ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: shift.assignedDrivers.length,
                 itemBuilder: (context, index) {
                   return AppCard(
                     margin: const EdgeInsets.only(bottom: 8),
                     padding: const EdgeInsets.all(12),
                     child: Row(
                       children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.user, color: AppColors.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(shift.assignedDrivers[index], style: AppTextStyle.body, fontWeight: FontWeight.bold),
                                AppText('Driver', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined, color: AppColors.errorColor),
                            onPressed: () {
                              Get.snackbar('Removed', 'Driver removed from shift.', snackPosition: SnackPosition.BOTTOM);
                            },
                          ),
                       ],
                     ),
                   );
                 },
               )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary),
          ),
          Expanded(
            flex: 3,
            child: AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.bold, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
