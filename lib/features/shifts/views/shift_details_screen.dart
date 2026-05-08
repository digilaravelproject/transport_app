import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../controllers/shift_controller.dart';
import '../domain/models/shift_model.dart';
import '../../../routes/route_helper.dart';

class ShiftDetailsScreen extends GetView<ShiftController> {
  const ShiftDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final ShiftModel? shift = args is ShiftModel 
        ? args 
        : (args is Map<String, dynamic> ? ShiftModel.fromJson(args) : null);

    if (shift == null) {
      return const AppScaffold(
        appBar: AppHeader(title: 'Shift Details'),
        body: Center(child: Text("Shift information not found")),
      );
    }
    
    // Fetch shift details on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shift.id != null) {
        controller.getShiftDetails(shift.id!);
      }
    });

    return AppScaffold(
      appBar: AppHeader(
        title: 'Shift Details',
        rightWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
              onPressed: () {
                if (shift.id != null) {
                  Get.toNamed(
                    RouteHelper.getCreateShiftRoute(),
                    arguments: {
                      'isEdit': true,
                      'shift': controller.currentShift.value ?? shift,
                    },
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.errorColor),
              onPressed: () => _showDeleteConfirmationDialog(context, shift),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: AppButton(
            text: 'Assign Drivers',
            onPressed: () {
              final shift = controller.currentShift.value;
              if (shift != null && shift.id != null) {
                Get.toNamed(
                  RouteHelper.getAssignDriverToShiftRoute(),
                  arguments: shift.id,
                );
              } else {
                CustomSnackbar.showError('Shift ID not found');
              }
            },
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        final displayShift = controller.currentShift.value ?? shift;
        final bool hasDrivers = (displayShift.driversCount ?? 0) > 0;
        final Color iconColor = AppColors.primaryColor;

        return RefreshIndicator(
          onRefresh: () async {
            if (shift.id != null) {
              await controller.getShiftDetails(shift.id!);
            }
          },
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header Card ---
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Iconsax.clock, color: iconColor, size: 40),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(displayShift.name, style: AppTextStyle.heading, fontSize: 22),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: displayShift.type.toLowerCase() == 'overtime'
                                        ? AppColors.errorColor.withOpacity(0.08)
                                        : AppColors.successColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: AppText(
                                    displayShift.type.toUpperCase(),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: displayShift.type.toLowerCase() == 'overtime'
                                        ? AppColors.errorColor
                                        : AppColors.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 16),
                      _buildDetailRow(Iconsax.timer_1, 'Start Time', displayShift.formattedTimeRange?.split(' - ').first ?? displayShift.startTime),
                      const SizedBox(height: 12),
                      _buildDetailRow(Iconsax.timer_pause, 'End Time', displayShift.formattedTimeRange?.split(' - ').last ?? displayShift.endTime),
                      if (displayShift.notes != null && displayShift.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(Iconsax.note_2, 'Notes', displayShift.notes!),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // --- Assigned Drivers Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Assigned Drivers', 
                        fontSize: 16, 
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                      ),
                      if (hasDrivers)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: AppText('${displayShift.driversCount} DRIVERS', 
                            fontSize: 10, 
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
                
                if (!hasDrivers)
                  AppEmptyState(
                    title: 'No Drivers Assigned',
                    subtitle: 'This shift doesn\'t have any drivers assigned yet.',
                    icon: Iconsax.user_remove,
                  )
                else if (displayShift.drivers != null && displayShift.drivers!.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayShift.drivers!.length,
                    itemBuilder: (context, index) {
                      final driver = displayShift.drivers![index];
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.user, color: AppColors.primaryColor, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(driver.name, 
                                    style: AppTextStyle.body, 
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  if (driver.phone != null)
                                    AppText(driver.phone!, 
                                      style: AppTextStyle.caption, 
                                      color: AppColors.textColorSecondary,
                                      fontSize: 12,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Iconsax.close_circle, color: AppColors.errorColor, size: 22),
                              onPressed: () => _showRemoveDriverDialog(context, displayShift, driver),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                
                const SizedBox(height: 80), // Space for bottom button
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textColorSecondary),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary, fontSize: 14),
        ),
        Expanded(
          flex: 3,
          child: AppText(value, 
            style: AppTextStyle.body, 
            fontWeight: FontWeight.w700, 
            textAlign: TextAlign.right,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showRemoveDriverDialog(BuildContext context, ShiftModel shift, DriverModel driver) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.user_remove,
                  color: AppColors.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: AppText(
                  'Remove Driver',
                  style: AppTextStyle.subheading,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Are you sure you want to remove this driver from the shift?',
                style: AppTextStyle.body,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 8),
              AppText(
                '"${driver.name}"',
                style: AppTextStyle.body,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: AppText(
                'Cancel',
                style: AppTextStyle.body,
                color: AppColors.textColorSecondary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                if (shift.id != null && driver.id != null) {
                  await controller.removeDriverFromShift(shift.id!, driver.id!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                'Remove',
                style: AppTextStyle.body,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ShiftModel shift) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.trash,
                  color: AppColors.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: AppText(
                  'Delete Shift',
                  style: AppTextStyle.subheading,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Are you sure you want to delete this shift?',
                style: AppTextStyle.body,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 8),
              AppText(
                '"${shift.name}"',
                style: AppTextStyle.body,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: AppText(
                'Cancel',
                style: AppTextStyle.body,
                color: AppColors.textColorSecondary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                if (shift.id != null) {
                  await controller.deleteShift(shift.id!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                'Delete',
                style: AppTextStyle.body,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}
