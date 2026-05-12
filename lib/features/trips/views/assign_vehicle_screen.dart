import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../controllers/trip_controller.dart';

class AssignVehicleScreen extends StatefulWidget {
  const AssignVehicleScreen({Key? key}) : super(key: key);

  @override
  State<AssignVehicleScreen> createState() => _AssignVehicleScreenState();
}

class _AssignVehicleScreenState extends State<AssignVehicleScreen> {
  final controller = Get.find<TripController>();
  late String tripId;
  final selectedIds = <int>[].obs;

  @override
  void initState() {
    super.initState();
    tripId = Get.arguments.toString();
    controller.fetchAvailableVehicles();
  }

  @override
  Widget build(BuildContext context) {
    final trip = controller.selectedTrip.value;
    final maxAllowed = trip != null ? trip.vehicleCount - trip.assignedVehicles.length : 1;

    return AppScaffold(
      appBar: const AppHeader(title: 'Assign Vehicles'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Select up to $maxAllowed vehicles', style: AppTextStyle.caption, color: AppColors.primaryColor),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) {
                    // TODO: Implement local search
                  },
                  decoration: InputDecoration(
                    hintText: 'Search vehicle number or type...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    filled: true,
                    fillColor: AppColors.slate50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.availableVehicles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.availableVehicles.isEmpty) {
                return const Center(child: AppText('No available vehicles found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.availableVehicles.length,
                itemBuilder: (context, index) {
                  final v = controller.availableVehicles[index];
                  final bool isAvailable = v['status'] == 'available';
                  final int id = int.tryParse(v['id'].toString()) ?? 0;
                  
                  return Obx(() {
                    final isSelected = selectedIds.contains(id);
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      onTap: isAvailable ? () {
                        if (isSelected) {
                          selectedIds.remove(id);
                        } else {
                          if (selectedIds.length < maxAllowed) {
                            selectedIds.add(id);
                          } else {
                            Get.snackbar(
                              'Limit Reached', 
                              'You can only select up to $maxAllowed vehicles.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        }
                      } : null,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryColor : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Iconsax.bus,
                              color: isSelected ? Colors.white : AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(v['registration_number'] ?? 'N/A', style: AppTextStyle.subheading, fontSize: 16),
                                AppText('${v['type']} • ${v['seating_capacity']} Seats', style: AppTextStyle.caption),
                              ],
                            ),
                          ),
                          if (isAvailable)
                            Icon(
                              isSelected ? Iconsax.tick_circle5 : Iconsax.add_circle,
                              color: isSelected ? AppColors.primaryColor : AppColors.slate300,
                            )
                          else
                            AppStatusChip(status: v['status'].toString().capitalizeFirst!),
                        ],
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          text: selectedIds.isEmpty ? 'Select Vehicles' : 'Assign ${selectedIds.length} Vehicles',
          isLoading: controller.isAssigning.value,
          onPressed: selectedIds.isEmpty ? null : () async {
            final success = await controller.assignVehicles(tripId, selectedIds);
            if (success) {
              Get.back(closeOverlays: true);
            }
          },
        ),
      )),
    );
  }
}
