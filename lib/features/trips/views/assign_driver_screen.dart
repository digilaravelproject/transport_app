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

class AssignDriverScreen extends StatefulWidget {
  const AssignDriverScreen({Key? key}) : super(key: key);

  @override
  State<AssignDriverScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends State<AssignDriverScreen> {
  final controller = Get.find<TripController>();
  late String tripId;
  final selectedIds = <int>[].obs;

  @override
  void initState() {
    super.initState();
    tripId = Get.arguments.toString();
    controller.fetchAvailableDrivers();
  }

  @override
  Widget build(BuildContext context) {
    final trip = controller.selectedTrip.value;
    final maxAllowed = trip != null ? trip.vehicleCount - trip.assignedDrivers.length : 1;

    return AppScaffold(
      appBar: const AppHeader(title: 'Assign Drivers'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Select up to $maxAllowed drivers', style: AppTextStyle.caption, color: AppColors.primaryColor),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) {
                    // TODO: Implement local search
                  },
                  decoration: InputDecoration(
                    hintText: 'Search driver name...',
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
              if (controller.isLoading.value && controller.availableDrivers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.availableDrivers.isEmpty) {
                return const Center(child: AppText('No available drivers found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.availableDrivers.length,
                itemBuilder: (context, index) {
                  final d = controller.availableDrivers[index];
                  final bool isAvailable = d['status'] == 'available';
                  final int id = int.tryParse(d['id'].toString()) ?? 0;
                  
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
                              'You can only select up to $maxAllowed drivers.',
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
                              Iconsax.user,
                              color: isSelected ? Colors.white : AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(d['name'] ?? 'N/A', style: AppTextStyle.subheading, fontSize: 16),
                                AppText('Phone: ${d['contact'] ?? 'N/A'}', style: AppTextStyle.caption),
                              ],
                            ),
                          ),
                          if (isAvailable)
                            Icon(
                              isSelected ? Iconsax.tick_circle5 : Iconsax.add_circle,
                              color: isSelected ? AppColors.primaryColor : AppColors.slate300,
                            )
                          else
                            AppStatusChip(status: d['status'].toString().capitalizeFirst!),
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
          text: selectedIds.isEmpty ? 'Select Drivers' : 'Assign ${selectedIds.length} Drivers',
          isLoading: controller.isAssigning.value,
          onPressed: selectedIds.isEmpty ? null : () async {
            final success = await controller.assignDrivers(tripId, selectedIds);
            if (success) {
              Get.back(closeOverlays: true);
            }
          },
        ),
      )),
    );
  }
}
