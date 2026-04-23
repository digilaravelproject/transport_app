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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        final displayShift = controller.currentShift.value ?? shift;

        return SingleChildScrollView(
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
                            onPressed: () {
                              // TODO: Implement remove driver functionality
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
}
