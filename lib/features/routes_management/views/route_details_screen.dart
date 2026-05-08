import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/route_controller.dart';
import '../domain/models/route_model.dart';
import '../../../routes/route_helper.dart';

class RouteDetailsScreen extends StatefulWidget {
  const RouteDetailsScreen({Key? key}) : super(key: key);

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  final RouteController controller = Get.find<RouteController>();
  late String routeId;

  @override
  void initState() {
    super.initState();
    routeId = (Get.arguments as RouteModel?)?.id ?? '';
    if (routeId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchRouteDetails(routeId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Route Details',
        rightWidget: Obx(() {
          final route = controller.selectedRouteDetails.value?.id == routeId 
              ? controller.selectedRouteDetails.value! 
              : controller.routes.firstWhere(
                  (r) => r.id == routeId, 
                  orElse: () => Get.arguments as RouteModel
                );
          return IconButton(
            icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
            onPressed: () async {
              await Get.toNamed(RouteHelper.getCreateRouteRoute(), arguments: route);
              if (routeId.isNotEmpty) {
                controller.fetchRouteDetails(routeId);
              }
            },
          );
        }),
      ),
      // bottomNavigationBar: SafeArea(
      //   child: Padding(
      //     padding: const EdgeInsets.all(20),
      //     child: AppButton(
      //       text: 'Assign Bus to Route',
      //       onPressed: () {
      //         final route = controller.routes.firstWhere((r) => r.id == routeId, orElse: () => Get.arguments as RouteModel);
      //         Get.toNamed(RouteHelper.getAssignRouteRoute(), arguments: route);
      //       },
      //     ),
      //   ),
      // ),
      body: Obx(() {
        if (controller.isLoading.value && controller.routes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final route = controller.selectedRouteDetails.value?.id == routeId 
            ? controller.selectedRouteDetails.value! 
            : controller.routes.firstWhere(
                (r) => r.id == routeId, 
                orElse: () => Get.arguments as RouteModel
              );

        return RefreshIndicator(
          onRefresh: () async => await controller.fetchRouteDetails(routeId),
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Beautiful Header Card ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: route.isActive ? AppColors.successColor : AppColors.errorColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  route.isActive ? 'Active Route' : 'Inactive',
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.routing, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AppText(
                        route.routeName,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText('Total Distance', fontSize: 11, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Iconsax.map, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(child: AppText('${route.distanceKm} km', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(width: 1, height: 35, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText('Est. Duration', fontSize: 11, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Iconsax.clock, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(child: AppText(route.estimatedTime, fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // --- Detailed Waypoints Card ---
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.location5, color: AppColors.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const AppText('Route Stops', fontSize: 16, fontWeight: FontWeight.bold),
                        ],
                      ),
                     // const SizedBox(height: 24),
                      if (route.points.isNotEmpty)
                        ...List.generate(route.points.length, (index) {
                          final point = route.points[index];
                          return _buildTimelineStop(
                            point['name'] ?? 'Unknown', 
                            index == 0, 
                            index == route.points.length - 1,
                            subtitle: point['type'] == 'start' ? 'Start Point' : (point['type'] == 'end' ? 'Destination' : 'Intermediate Stop'),
                          );
                        })
                      else
                        Column(
                          children: [
                            _buildTimelineStop(route.origin, true, false, subtitle: 'Start Point'),
                            for (int i = 0; i < route.viaStops.length; i++)
                                _buildTimelineStop(route.viaStops[i], false, false, subtitle: 'Intermediate Stop'),
                            _buildTimelineStop(route.destination, false, true, subtitle: 'Destination'),
                          ],
                        ),
                    ],
                  ),
                ),

                // --- Schedules Card ---
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.calendar_tick, color: AppColors.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const AppText('Schedules & Frequency', fontSize: 16, fontWeight: FontWeight.bold),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (route.schedules.isNotEmpty)
                        ...route.schedules.map((s) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Iconsax.clock, size: 16, color: AppColors.textColorSecondary),
                                  const SizedBox(width: 8),
                                  AppText(
                                    '${s['departure_time'] ?? s['start_time'] ?? 'N/A'} - ${s['arrival_time'] ?? s['end_time'] ?? 'N/A'}',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: AppText(
                                          s['days'] is List ? (s['days'] as List).join(', ') : (s['days']?.toString() ?? 'Daily'),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )).toList()
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: AppText('No schedules defined for this route.', fontSize: 13, color: AppColors.textColorHint),
                          ),
                        ),
                    ],
                  ),
                ),

                // Assigned Bus Card
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Iconsax.bus, color: AppColors.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const AppText('Assigned Vehicle', fontSize: 16, fontWeight: FontWeight.bold),
                            ],
                          ),
                          if (route.assignedVehicles.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const AppText(
                                'Active',
                                fontSize: 10,
                                color: AppColors.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      if (route.assignedVehicles.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: AppText('Not assigned yet', fontSize: 14, color: AppColors.textColorHint),
                          ),
                        )
                      else ...[
                        // Bus Details
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          route.assignedVehicles.first.registrationNumber,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textColorPrimary,
                                        ),
                                        const SizedBox(height: 4),
                                        AppText(
                                          route.assignedVehicles.first.fullDisplayText.split(' • ').sublist(1).join(' • '),
                                          fontSize: 12,
                                          color: AppColors.textColorSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, color: AppColors.slate200),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildBusDetailItem('Model Year', route.assignedVehicles.first.modelYear.toString()),
                                  ),
                                  Container(width: 1, height: 30, color: AppColors.slate200),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildBusDetailItem('Type', route.assignedVehicles.first.type.toUpperCase()),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Bus Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Get.toNamed(RouteHelper.getAssignRouteRoute(), arguments: route);
                            controller.fetchRouteDetails(routeId);
                          },
                          icon: Icon(route.assignedVehicles.isEmpty ? Iconsax.add : Iconsax.refresh, size: 18),
                          label: AppText(
                            route.assignedVehicles.isEmpty ? 'Assign Vehicle' : 'Change Vehicle',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            side: const BorderSide(color: AppColors.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Assigned Driver Card
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Iconsax.user, color: AppColors.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const AppText('Assigned Driver', fontSize: 16, fontWeight: FontWeight.bold),
                            ],
                          ),
                          if (route.assignedDrivers.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const AppText(
                                'Active',
                                fontSize: 10,
                                color: AppColors.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      if (route.assignedDrivers.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: AppText('Not assigned yet', fontSize: 14, color: AppColors.textColorHint),
                          ),
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          route.assignedDrivers.first.name,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textColorPrimary,
                                        ),
                                        const SizedBox(height: 4),
                                        AppText(
                                          route.assignedDrivers.first.phone,
                                          fontSize: 12,
                                          color: AppColors.textColorSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, color: AppColors.slate200),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDriverDetailItem('Address ', route.assignedDrivers.first.address ?? 'N/A'),
                                  ),
                                  // Container(width: 1, height: 30, color: AppColors.slate200),
                                  // const SizedBox(width: 16),
                                  // Expanded(
                                  //   child: _buildDriverDetailItem('Shift', route.assignedDrivers.first.shiftName ?? 'N/A'),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Driver Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Get.toNamed(RouteHelper.getAssignRouteDriver(), arguments: route);
                            controller.fetchRouteDetails(routeId);
                          },
                          icon: Icon(route.assignedDrivers.isEmpty ? Iconsax.user_add : Iconsax.user_edit, size: 18),
                          label: AppText(
                            route.assignedDrivers.isEmpty ? 'Assign Driver' : 'Change Driver',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            side: const BorderSide(color: AppColors.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBusDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 11,
          color: AppColors.textColorSecondary,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 2),
        AppText(
          value,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
      ],
    );
  }

  Widget _buildDriverDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 11,
          color: AppColors.textColorSecondary,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 2),
        AppText(
          value,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
      ],
    );
  }



  Widget _buildTimelineStop(String name, bool isFirst, bool isLast, {String? subtitle}) {
    Color nodeColor = isFirst ? AppColors.primaryColor : (isLast ? AppColors.errorColor : AppColors.textColorSecondary);
    IconData nodeIcon = isFirst ? Icons.place_rounded : (isLast ? Icons.flag_rounded : Icons.circle);
    double iconSize = isFirst || isLast ? 22 : 12;

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.slate300, AppColors.slate300.withOpacity(0.1)],
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 12),
                
                Icon(nodeIcon, color: nodeColor, size: iconSize),
                
                if (!isLast)
                   Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.slate300, AppColors.slate300.withOpacity(0.1)],
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    name,
                    fontSize: 15,
                    fontWeight: isFirst || isLast ? FontWeight.w800 : FontWeight.w700,
                    color: AppColors.textColorPrimary,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: AppText(
                        subtitle, 
                        fontSize: 12, 
                        color: AppColors.textColorSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
