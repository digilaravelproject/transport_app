import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_header.dart';
import '../controllers/vehicle_type_controller.dart';
import '../domain/models/vehicle_type_model.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_text_constants.dart';
import '../../../core/widgets/app_empty_state.dart';

class VehicleTypeListScreen extends StatefulWidget {
  const VehicleTypeListScreen({Key? key}) : super(key: key);

  @override
  State<VehicleTypeListScreen> createState() => _VehicleTypeListScreenState();
}

class _VehicleTypeListScreenState extends State<VehicleTypeListScreen> {
  final controller = Get.find<VehicleTypeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.fetchVehicleTypes(isRefresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: AppTextConstants.vehicleTypesDashboard.tr,
        subtitle: AppTextConstants.manageConfigureVehicleTypes.tr,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getAddVehicleTypeRoute()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppSearchBar(
              hint: AppTextConstants.searchVehicleTypes.tr,
              onChanged: (val) => controller.updateSearch(val),
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchVehicleTypes(),
              color: AppColors.primaryColor,
              child: Obx(() {
                if (controller.isLoading.value && controller.vehicleTypes.isEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (context, index) => const _VehicleTypeShimmer(),
                  );
                }

                if (controller.vehicleTypes.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: AppEmptyState(
                        title: controller.searchQuery.value.isNotEmpty ? AppTextConstants.noResultsFound.tr : AppTextConstants.noVehicleTypesFound.tr,
                        subtitle: controller.searchQuery.value.isNotEmpty 
                            ? '${AppTextConstants.noResultsFound.tr} "${controller.searchQuery.value}".'
                            : AppTextConstants.startAddingVehicleType.tr,
                        icon: controller.searchQuery.value.isNotEmpty ? Iconsax.search_status : Iconsax.bus5,
                        actionLabel: controller.searchQuery.value.isNotEmpty ? null : AppTextConstants.addVehicleType.tr,
                        onActionPressed: controller.searchQuery.value.isNotEmpty ? null : () => Get.toNamed(RouteHelper.getAddVehicleTypeRoute()),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: controller.vehicleTypes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.vehicleTypes.length) {
                      return controller.isLoadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                            )
                          : const SizedBox();
                    }
                    final type = controller.vehicleTypes[index];
                    return _VehicleTypeCard(type: type);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final VehicleTypeModel type;
  const _VehicleTypeCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => Get.toNamed(RouteHelper.getEditVehicleTypeRoute(), arguments: type),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.bus5, color: AppColors.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            type.name,
                            style: AppTextStyle.subheading,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          if (type.description != null && type.description!.isNotEmpty)
                            AppText(
                              type.description!,
                              style: AppTextStyle.caption,
                              color: AppColors.textColorSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppStatusChip(status: type.isActive ? 'active' : 'inactive', fontSize: 10),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            children: [
              _buildInfoItem(AppTextConstants.seatingCapacity.tr, '${type.capacity}', Iconsax.user, AppColors.infoColor),
              _buildInfoItem(AppTextConstants.pricePerKm.tr, '₹${type.perKmPrice}', Iconsax.money_send, AppColors.successColor),
              _buildInfoItem(AppTextConstants.acExtra.tr, '₹${type.acPricePerKm}', Iconsax.flash5, AppColors.warningColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: AppTextConstants.configure.tr,
                width: 100,
                height: 32,
                fontSize: 12,
                onPressed: () => Get.toNamed(RouteHelper.getEditVehicleTypeRoute(), arguments: type),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label, style: AppTextStyle.caption, fontSize: 9, color: AppColors.textColorHint),
                AppText(value, style: AppTextStyle.body, fontSize: 12, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTypeShimmer extends StatelessWidget {
  const _VehicleTypeShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.slate100,
      highlightColor: AppColors.white,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(height: 40, width: 40, decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Container(height: 20, width: 120, color: AppColors.white),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 40, width: double.infinity, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
