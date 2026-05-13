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
import '../controllers/corporate_controller.dart';
import '../../../core/constants/app_text_constants.dart';

class AssignVehicleToContractScreen extends StatefulWidget {
  const AssignVehicleToContractScreen({Key? key}) : super(key: key);

  @override
  State<AssignVehicleToContractScreen> createState() => _AssignVehicleToContractScreenState();
}

class _AssignVehicleToContractScreenState extends State<AssignVehicleToContractScreen> {
  final CorporateController controller = Get.find<CorporateController>();
  final RxList<int> _selectedVehicleIds = <int>[].obs;
  late String vendorId;

  @override
  void initState() {
    super.initState();
    vendorId = Get.arguments.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAvailableVehicles(vendorId, isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.availableVehicles.tr,
        subtitle: AppTextConstants.selectVehiclesToAssign.tr,
      ),
      floatingActionButton: Obx(() => _selectedVehicleIds.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: controller.isLoading.value 
                ? null 
                : () async {
                    bool success = await controller.assignVehicles(vendorId, _selectedVehicleIds);
                    if (success) {
                      controller.loadVendorDetails(vendorId);
                      Get.back();
                    }
                  },
              backgroundColor: AppColors.primaryColor,
              label: controller.isLoading.value 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : AppText(AppTextConstants.assignVehiclesCount.trParams({'count': _selectedVehicleIds.length.toString()}), 
                    style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
              icon: controller.isLoading.value ? null : const Icon(Iconsax.tick_circle, color: Colors.white),
            )
          : const SizedBox.shrink()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: AppTextConstants.searchVehicleNo.tr,
              onChanged: (v) => controller.updateVehicleSearch(vendorId, v),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isAvailableVehiclesLoading.value && controller.availableVehicles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.availableVehicles.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.loadAvailableVehicles(vendorId, isRefresh: true),
                  child: ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          children: [
                            Icon(Iconsax.bus, size: 64, color: AppColors.slate300),
                            const SizedBox(height: 16),
                            AppText(AppTextConstants.noAvailableVehiclesFound.tr, 
                              style: AppTextStyle.body, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadAvailableVehicles(vendorId, isRefresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: controller.availableVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = controller.availableVehicles[index];
                    final int id = vehicle['id'];
                    final isSelected = _selectedVehicleIds.contains(id);
                    
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      child: Obx(() => CheckboxListTile(
                        value: _selectedVehicleIds.contains(id),
                        activeColor: AppColors.primaryColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: AppText(vehicle['registration_number'] ?? 'N/A', 
                          style: AppTextStyle.body, fontWeight: FontWeight.bold),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            AppText(vehicle['type'] ?? 'N/A', 
                              style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                            AppText('${AppTextConstants.capacity.tr}: ${vehicle['seating_capacity'] ?? 'N/A'}', 
                              style: AppTextStyle.caption, color: AppColors.textColorSecondary, fontSize: 10),
                          ],
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Iconsax.bus, color: AppColors.primaryColor, size: 24),
                        ),
                        onChanged: (bool? value) {
                          if (value == true) {
                            _selectedVehicleIds.add(id);
                          } else {
                            _selectedVehicleIds.remove(id);
                          }
                        },
                      )),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
