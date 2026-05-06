import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/route_controller.dart';
import '../domain/models/route_model.dart';

class AssignRouteDriverScreen extends StatefulWidget {
  const AssignRouteDriverScreen({Key? key}) : super(key: key);

  @override
  State<AssignRouteDriverScreen> createState() => _AssignRouteScreenState();
}

class _AssignRouteScreenState extends State<AssignRouteDriverScreen> {
  final RouteController controller = Get.find<RouteController>();
  RouteModel? _selectedRoute;

  @override
  void initState() {
    super.initState();
    // Pre-select if navigated from route details
    if (Get.arguments is RouteModel) {
      _selectedRoute = Get.arguments;
      final routeId = int.tryParse(_selectedRoute!.id);
      if (routeId != null) {
        // Fetch drivers for this specific route
        controller.loadAvailableDrivers(routeId);
      }
    }
    // Clear previous selection
    controller.clearDriverSelection();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Assign Route Driver',
      ),
      floatingActionButton: Obx(() => controller.selectedDriver.value != null && _selectedRoute != null
          ? FloatingActionButton.extended(
        heroTag: null,
        onPressed: () async {
          final driver = controller.selectedDriver.value!;
          final route = _selectedRoute!;

          // Convert route ID to int
          final routeId = int.tryParse(route.id);
          if (routeId == null) {
            CustomSnackbar.showError('Invalid route ID');
            return;
          }

          // Show bottom sheet for dates
          _showAssignDriverBottomSheet(context, routeId, driver.id);
        },
        backgroundColor: AppColors.primaryColor,
        label: const AppText(
          'Assign Driver',
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

          if (_selectedRoute != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: AppSearchBar(
                hint: 'Search driver...',
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
                          Iconsax.user,
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
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final routeId = int.tryParse(_selectedRoute!.id);
                    if (routeId != null) {
                      await controller.loadAvailableDrivers(routeId);
                    }
                  },
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      return Obx(() {
                        final isSelected = controller.selectedDriver.value?.id == driver.id;
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor : Colors.transparent,
                            width: 2,
                          ),
                          onTap: () => controller.selectDriver(driver),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor.withOpacity(0.1)
                                      : AppColors.slate50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Iconsax.user,
                                  color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      driver.name,
                                      style: AppTextStyle.body,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      driver.phone,
                                      style: AppTextStyle.caption,
                                      color: AppColors.textColorSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.successColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const AppText(
                                            'Available',
                                            fontSize: 10,
                                            color: AppColors.successColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (driver.shiftName != null) ...[
                                          const SizedBox(width: 8),
                                          AppText(
                                            driver.shiftName!,
                                            fontSize: 10,
                                            color: AppColors.textColorSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        );
                      });
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 80), // Prevent FAB overlap
          ] else ...[
            const Expanded(
              child: Center(
                child: AppText('Please select a route first.', style: AppTextStyle.body, color: AppColors.textColorSecondary),
              ),
            )
          ]
        ],
      ),
    );
  }

  void _showAssignDriverBottomSheet(BuildContext context, int routeId, int driverId) {
    DateTime? fromDate;
    DateTime? toDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Assign Driver',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 20),
                  // From Date
                  AppText('From Date', style: AppTextStyle.label),
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: fromDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setState(() {
                          fromDate = date;
                          if (toDate != null && toDate!.isBefore(fromDate!)) {
                            toDate = null; // reset if invalid
                          }
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: fromDate != null 
                          ? DateFormat('yyyy-MM-dd').format(fromDate!) 
                          : 'Select From Date',
                      suffixIcon: const Icon(Iconsax.calendar),
                      filled: true,
                      fillColor: AppColors.slate50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // To Date
                  AppText('To Date', style: AppTextStyle.label),
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: toDate ?? (fromDate ?? DateTime.now()),
                        firstDate: fromDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setState(() => toDate = date);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: toDate != null 
                          ? DateFormat('yyyy-MM-dd').format(toDate!) 
                          : 'Select To Date',
                      suffixIcon: const Icon(Iconsax.calendar),
                      filled: true,
                      fillColor: AppColors.slate50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () async {
                        if (fromDate == null || toDate == null) {
                          CustomSnackbar.showError('Please select both from and to dates');
                          return;
                        }
                        Navigator.pop(context); // Close bottom sheet
                        await controller.assignDriverToRoute(routeId, driverId, fromDate!, toDate!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const AppText('Assign Driver', color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}