import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/corporate_controller.dart';
import '../../../core/constants/app_text_constants.dart';

class AssignDriverToContractScreen extends StatefulWidget {
  const AssignDriverToContractScreen({Key? key}) : super(key: key);

  @override
  State<AssignDriverToContractScreen> createState() =>
      _AssignDriverToContractScreenState();
}

class _AssignDriverToContractScreenState
    extends State<AssignDriverToContractScreen> {
  final CorporateController controller = Get.find<CorporateController>();
  final RxList<int> selectedDrivers = <int>[].obs;
  late final String vendorId;

  @override
  void initState() {
    super.initState();
    // Assuming vendorId is passed as an argument, fallback to selectedVendor id
    vendorId = Get.arguments?.toString() ?? controller.selectedVendor.value?.id ?? '19';
    controller.loadAvailableDrivers(vendorId);
  }

  void toggleSelect(int id) {
    if (selectedDrivers.contains(id)) {
      selectedDrivers.remove(id);
    } else {
      selectedDrivers.add(id);
    }
    selectedDrivers.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.assignDriver.tr,
        subtitle: AppTextConstants.selectDriversToAssign.tr,
      ),

      floatingActionButton: Obx(() {
        return selectedDrivers.isNotEmpty
            ? FloatingActionButton.extended(
          onPressed: () async {
            final success = await controller.assignDrivers(vendorId, selectedDrivers);
            if (success) {
              Get.back(result: true);
            }
          },
          backgroundColor: AppColors.primaryColor,
          icon: const Icon(Iconsax.tick_circle, color: Colors.white),
          label: AppText(
            '${AppTextConstants.assign.tr} ${selectedDrivers.length} ${AppTextConstants.drivers.tr}',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
            : const SizedBox.shrink();
      }),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: AppTextConstants.searchDriverHint.tr,
              onChanged: (v) => controller.updateDriverSearch(vendorId, v),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isAvailableDriversLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.availableDrivers;

              if (list.isEmpty) {
                return Center(
                  child: AppText(AppTextConstants.noStaffFound.tr),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final driver = list[index];
                  final int id = int.tryParse(driver['id'].toString()) ?? 0;

                  return Obx(() {
                    final bool isSelected = selectedDrivers.contains(id);

                    return GestureDetector(
                      onTap: () => toggleSelect(id),

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.25),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.primaryLight,
                            ),
                            child: Icon(
                              Icons.person,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryColor,
                            ),
                          ),

                          title: AppText(
                            driver['name'] ?? AppTextConstants.unknown.tr,
                            fontWeight: FontWeight.bold,
                            style: AppTextStyle.body,
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              AppText(
                                "${AppTextConstants.phone.tr}: ${driver['phone'] ?? 'N/A'}",
                                style: AppTextStyle.caption,
                              ),
                              AppText(
                                driver['address'] ?? AppTextConstants.notSpecified.tr,
                                color: AppColors.textColorSecondary,
                                style: AppTextStyle.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: isSelected 
                            ? const Icon(Iconsax.tick_circle5, color: AppColors.primaryColor)
                            : Icon(Iconsax.add_circle, color: Colors.grey.shade400),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}