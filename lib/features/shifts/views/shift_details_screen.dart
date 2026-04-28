import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../controllers/shift_controller.dart';
import '../domain/models/shift_model.dart';
import '../../../routes/route_helper.dart';

class ShiftDetailsScreen extends GetView<ShiftController> {
  const ShiftDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null) {
      return const AppScaffold(
        appBar: AppHeader(title: 'Shift Details'),
        body: Center(child: Text("No shift selected")),
      );
    }

    final ShiftModel shift = Get.arguments;
    
    // Fetch shift details on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shift.id != null) {
        controller.getShiftDetails(shift.id!);
      }
    });

    bool hasDrivers = (shift.driversCount ?? 0) > 0;

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
          padding: const EdgeInsets.all(20),
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

        return RefreshIndicator(
          onRefresh: () async {
            if (shift.id != null) {
              await controller.getShiftDetails(shift.id!);
            }
          },
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      AppText(displayShift.name, style: AppTextStyle.heading, fontSize: 24),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: displayShift.type.toLowerCase() == 'overtime'
                              ? AppColors.errorColor.withOpacity(0.1)
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          displayShift.type.replaceFirst(displayShift.type[0], displayShift.type[0].toUpperCase()),
                          style: AppTextStyle.caption,
                          color: displayShift.type.toLowerCase() == 'overtime'
                              ? AppColors.errorColor
                              : AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
                      _buildDetailRow('Start Time', displayShift.formattedTimeRange?.split(' - ').first ?? displayShift.startTime),
                      _buildDetailRow('End Time', displayShift.formattedTimeRange?.split(' - ').last ?? displayShift.endTime),
                      if (displayShift.notes != null && displayShift.notes!.isNotEmpty)
                        _buildDetailRow('Notes', displayShift.notes!),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText('Assigned Drivers', style: AppTextStyle.subheading),
                    if (hasDrivers)
                      AppText(
                        '${displayShift.driversCount}',
                        style: AppTextStyle.body,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!hasDrivers) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.errorColor.withOpacity(0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.group_off_outlined, color: AppColors.errorColor, size: 32),
                        const SizedBox(height: 8),
                        AppText(
                          'No drivers currently assigned to this shift.',
                          style: AppTextStyle.caption,
                          color: AppColors.errorColor,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else if (displayShift.drivers != null && displayShift.drivers!.isNotEmpty) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayShift.drivers!.length,
                    itemBuilder: (context, index) {
                      final driver = displayShift.drivers![index];
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
                                  AppText(driver.name, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                                  if (driver.phone != null)
                                    AppText(driver.phone!, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: AppColors.errorColor),
                              onPressed: () => _showRemoveDriverDialog(context, displayShift, driver),
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
      }),
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
                  Icons.person_remove,
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
              const SizedBox(height: 12),
              AppText(
                'The driver will no longer be assigned to this shift.',
                style: AppTextStyle.caption,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: AppText(
                'Cancel',
                style: AppTextStyle.body,
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back(); // Close dialog first
                
                if (shift.id != null && driver.id != null) {
                  await controller.removeDriverFromShift(shift.id!, driver.id!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                'Remove',
                style: AppTextStyle.body,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
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
              const SizedBox(height: 12),
              AppText(
                'This action cannot be undone.',
                style: AppTextStyle.caption,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: AppText(
                'Cancel',
                style: AppTextStyle.body,
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back(); // Close dialog first
                
                if (shift.id != null) {
                  await controller.deleteShift(shift.id!);
                  
                  // Check if deletion was successful
                  if (controller.isSuccess.value) {
                    // Wait a bit for the snackbar to show, then navigate back
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Get.back(); // Go back to shift list
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                'Delete',
                style: AppTextStyle.body,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
