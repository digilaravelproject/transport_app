import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../controllers/route_controller.dart';
import '../domain/models/route_model.dart';
import '../../../routes/route_helper.dart';
import '../../../core/widgets/app_empty_state.dart';

class RouteListScreen extends GetView<RouteController> {
  const RouteListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Routes',
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getCreateRouteRoute()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const AppText('Create Route', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search routes...',
              onChanged: (v) => controller.updateSearch(v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Row(
              children: [
                AppFilterChip(
                  label: 'All',
                  isSelected: controller.selectedFilter.value == 'All',
                  onTap: () => controller.setFilter('All'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'Active',
                  isSelected: controller.selectedFilter.value == 'Active',
                  onTap: () => controller.setFilter('Active'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'Inactive',
                  isSelected: controller.selectedFilter.value == 'Inactive',
                  onTap: () => controller.setFilter('Inactive'),
                ),
              ],
            )),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
               if (controller.isLoading.value && controller.routes.isEmpty) {
                 return const Center(child: CircularProgressIndicator());
               }
               
               if (controller.filteredRoutes.isEmpty) {
                 return RefreshIndicator(
                   onRefresh: () => controller.fetchRoutes(),
                   child: SingleChildScrollView(
                     physics: const AlwaysScrollableScrollPhysics(),
                     child: SizedBox(
                       height: MediaQuery.of(context).size.height * 0.6,
                       child: AppEmptyState(
                         title: 'No Routes Found',
                         subtitle: controller.searchQuery.value.isNotEmpty 
                             ? 'No routes match your search "${controller.searchQuery.value}".'
                             : 'Start by creating your first route to manage transport paths.',
                         icon: Iconsax.map,
                       ),
                     ),
                   ),
                 );
               }
               
               return RefreshIndicator(
                 onRefresh: () => controller.fetchRoutes(),
                 child: ListView.builder(
                   padding: const EdgeInsets.all(16),
                   itemCount: controller.filteredRoutes.length,
                   itemBuilder: (context, index) {
                     return _buildRouteItem(controller.filteredRoutes[index]);
                   },
                 ),
               );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(RouteModel route) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed(RouteHelper.getRouteDetailsRoute(), arguments: route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(route.routeName, style: AppTextStyle.subheading, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: route.isActive ? AppColors.successColor.withOpacity(0.1) : AppColors.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  route.isActive ? 'Active' : 'Inactive',
                  style: AppTextStyle.caption,
                  color: route.isActive ? AppColors.successColor : AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place_rounded, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Expanded(child: AppText(route.origin, style: AppTextStyle.body)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7.0),
            child: Container(
              height: 12,
              width: 2,
              color: AppColors.slate300,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 16, color: AppColors.errorColor),
              const SizedBox(width: 8),
              Expanded(child: AppText(route.destination, style: AppTextStyle.body)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.map, size: 16, color: AppColors.textColorSecondary),
                  const SizedBox(width: 8),
                  AppText('${route.distanceKm} km', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textColorSecondary),
                  const SizedBox(width: 8),
                  AppText(route.estimatedTime, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textColorSecondary),
                  const SizedBox(width: 8),
                  AppText(
                    route.schedules.isNotEmpty 
                      ? (() {
                          final days = route.schedules[0]['days'];
                          if (days is List) {
                            return days.contains('Daily') ? 'Daily' : days.join(', ');
                          }
                          return days?.toString() ?? 'N/A';
                        })()
                      : 'No Schedule',
                    style: AppTextStyle.caption, 
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
