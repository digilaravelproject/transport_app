import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../controllers/route_controller.dart';
import '../domain/models/route_model.dart';

class AssignRouteScreen extends StatefulWidget {
  const AssignRouteScreen({Key? key}) : super(key: key);

  @override
  State<AssignRouteScreen> createState() => _AssignRouteScreenState();
}

class _AssignRouteScreenState extends State<AssignRouteScreen> {
  final RouteController controller = Get.find<RouteController>();
  RouteModel? _selectedRoute;

  @override
  void initState() {
    super.initState();
    // Pre-select if navigated from route details
    if (Get.arguments is RouteModel) {
      _selectedRoute = Get.arguments;
    }
    // Clear previous vehicle selection
    controller.clearVehicleSelection();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Assign Route',
      ),
      floatingActionButton: Obx(() => controller.selectedVehicle.value != null && _selectedRoute != null
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () async {
                final vehicle = controller.selectedVehicle.value!;
                final route = _selectedRoute!;
                
                // Convert route ID to int
                final routeId = int.tryParse(route.id);
                if (routeId == null) {
                  CustomSnackbar.showError('Invalid route ID');
                  return;
                }
                
                // Call the assign vehicle API
                await controller.assignVehicleToRoute(routeId, vehicle.id);
              },
              backgroundColor: AppColors.primaryColor,
              label: AppText(
                'Assign Vehicle',
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
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
            child: _buildRouteDropdown(),
          ),
          if (_selectedRoute != null) ...[
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                child: AppSearchBar(
                  hint: 'Search vehicle number...',
                  onChanged: (value) => controller.updateVehicleSearch(value),
                ),
             ),
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                     const AppText('Select Vehicle', style: AppTextStyle.subheading),
                     const Spacer(),
                     Obx(() => AppText(
                       controller.selectedVehicle.value != null ? '1 selected' : '0 selected',
                       style: AppTextStyle.caption,
                       color: AppColors.primaryColor,
                       fontWeight: FontWeight.bold,
                     )),
                  ],
                ),
             ),
             Expanded(
                child: Obx(() {
                  if (controller.isVehiclesLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  final vehicles = controller.filteredVehicles;

                  if (vehicles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.bus,
                            size: 64,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          AppText(
                            controller.vehicleSearchQuery.value.isNotEmpty
                                ? 'No vehicles found for "${controller.vehicleSearchQuery.value}"'
                                : 'No vehicles available',
                            style: AppTextStyle.body,
                            color: AppColors.textColorSecondary,
                          ),
                          //const SizedBox(height: 16),
                          // AppButton(
                          //   text: 'Refresh',
                          //   onPressed: () => controller.refreshVehicles(),
                          // ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.refreshVehicles(),
                    color: AppColors.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return Obx(() {
                          final isSelected = controller.selectedVehicle.value?.id == vehicle.id;
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : Colors.transparent,
                              width: 2,
                            ),
                            onTap: () => controller.selectVehicle(vehicle),
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
                                    Iconsax.bus,
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
                                        vehicle.registrationNumber,
                                        style: AppTextStyle.body,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                                      ),
                                      const SizedBox(height: 4),
                                      AppText(
                                        '${vehicle.make} ${vehicle.model} • ${vehicle.seatingCapacity} Seater',
                                        style: AppTextStyle.caption,
                                        color: AppColors.textColorSecondary,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: vehicle.isAvailable 
                                                  ? AppColors.successColor.withOpacity(0.1)
                                                  : AppColors.errorColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: AppText(
                                              vehicle.isAvailable ? 'Available' : 'Not Available',
                                              fontSize: 10,
                                              color: vehicle.isAvailable 
                                                  ? AppColors.successColor 
                                                  : AppColors.errorColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          AppText(
                                            '${vehicle.fuelType.toUpperCase()} • ${vehicle.currentKm} km',
                                            fontSize: 10,
                                            color: AppColors.textColorSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
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

  Widget _buildRouteDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Select Route', style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRoute?.id,
          hint: const Text('Choose a route to assign'),
          items: controller.routes.map((route) {
            return DropdownMenuItem<String>(
              value: route.id,
              child: Text(route.routeName),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedRoute = controller.routes.firstWhere((r) => r.id == val);
              });
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }
}
