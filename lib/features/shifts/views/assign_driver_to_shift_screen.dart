import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../controllers/shift_controller.dart';
import '../domain/models/shift_model.dart';

class AssignDriverToShiftScreen extends StatefulWidget {
  const AssignDriverToShiftScreen({Key? key}) : super(key: key);

  @override
  State<AssignDriverToShiftScreen> createState() => _AssignDriverToShiftScreenState();
}

class _AssignDriverToShiftScreenState extends State<AssignDriverToShiftScreen> {
  final ShiftController controller = Get.find<ShiftController>();
  int? shiftId;

  @override
  void initState() {
    super.initState();
    // Get shift ID from arguments
    shiftId = Get.arguments as int?;
    
    // Load drivers for this specific shift
    if (shiftId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('Loading drivers for shift ID: $shiftId');
        controller.loadAvailableDriversForShift(shiftId!);
      });
    } else {
      print('ERROR: No shift ID provided to AssignDriverToShiftScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return AppScaffold(
      appBar: AppHeader(
        title: 'Assign Drivers',
        rightWidget: IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textColorPrimary),
          onPressed: () {
            if (shiftId != null) {
              controller.loadAvailableDriversForShift(shiftId!);
            }
          },
        ),
      ),
      floatingActionButton: Obx(() => controller.selectedDriverIds.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () async {
                if (shiftId != null) {
                  await controller.assignDriversToShift(shiftId!);
                  Get.back();
                } else {
                  CustomSnackbar.showError('Shift ID not found');
                }
              },
              backgroundColor: AppColors.primaryColor,
              label: AppText(
                'Assign ${controller.selectedDriverIds.length} Drivers',
                style: AppTextStyle.body,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              icon: const Icon(Iconsax.tick_circle, color: Colors.white),
            )
          : const SizedBox.shrink()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search driver name or phone...',
              onChanged: (value) => controller.updateDriverSearch(value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isDriversLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              final drivers = controller.filteredDrivers;

              if (drivers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.user_remove,
                        size: 64,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        controller.driverSearchQuery.value.isNotEmpty
                            ? 'No drivers found for "${controller.driverSearchQuery.value}"'
                            : 'No drivers available',
                        style: AppTextStyle.body,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 16),
                      /*AppButton(
                        text: 'Refresh',
                        onPressed: () {
                          if (shiftId != null) {
                            controller.loadAvailableDriversForShift(shiftId!);
                          }
                        },
                      ),*/
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () {
                  if (shiftId != null) {
                    return controller.loadAvailableDriversForShift(shiftId!);
                  }
                  return Future.value();
                },
                color: AppColors.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    return Obx(() {
                      final isSelected = controller.selectedDriverIds.contains(driver.id.toString());
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        child: CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          title: AppText(
                            driver.name,
                            style: AppTextStyle.body,
                            fontWeight: FontWeight.bold,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                driver.phone ?? 'No phone',
                                style: AppTextStyle.caption,
                                color: AppColors.textColorSecondary,
                              ),
                              if (driver.licenseNumber != null)
                                AppText(
                                  'License: ${driver.licenseNumber}',
                                  style: AppTextStyle.caption,
                                  color: AppColors.textColorSecondary,
                                ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (driver.isAvailable ?? false) ? AppColors.successColor.withOpacity(0.1) : AppColors.errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AppText(
                                  (driver.isAvailable ?? false) ? 'Available' : 'Not Available',
                                  style: AppTextStyle.caption,
                                  color: (driver.isAvailable ?? false) ? AppColors.successColor : AppColors.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.user, color: AppColors.primaryColor, size: 20),
                          ),
                          onChanged: (bool? value) {
                            controller.toggleDriverSelection(driver.id.toString());
                          },
                        ),
                      );
                    });
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 80), // Prevent FAB overlap
        ],
      ),
    );
  }
}
