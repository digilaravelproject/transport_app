import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/route_controller.dart';
import '../domain/models/route_model.dart';
import '../../../routes/route_helper.dart';

class RouteDetailsScreen extends GetView<RouteController> {
  const RouteDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String routeId = (Get.arguments as RouteModel?)?.id ?? '';
    
    return AppScaffold(
      appBar: AppHeader(
        title: 'Route Details',
        rightWidget: Obx(() {
          final route = controller.routes.firstWhere((r) => r.id == routeId, orElse: () => Get.arguments as RouteModel);
          return IconButton(
            icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
            onPressed: () => Get.toNamed(RouteHelper.getCreateRouteRoute(), arguments: route),
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

        final route = controller.routes.firstWhere(
          (r) => r.id == routeId, 
          orElse: () => Get.arguments as RouteModel
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Card ---
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                borderRadius: 0,
                boxShadow: const [],
                border: Border.all(color: Colors.transparent, width: 0),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.05), width: 6),
                      ),
                      child: const Center(
                        child: Icon(
                          Iconsax.routing,
                          color: AppColors.primaryColor,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppText(
                      route.routeName, 
                      fontSize: 24, 
                      fontWeight: FontWeight.w800, 
                      textAlign: TextAlign.center,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: route.isActive ? AppColors.successColor.withOpacity(0.08) : AppColors.errorColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: route.isActive ? AppColors.successColor.withOpacity(0.1) : AppColors.errorColor.withOpacity(0.1),
                          width: 1,
                        ),
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
                              boxShadow: [
                                BoxShadow(
                                  color: (route.isActive ? AppColors.successColor : AppColors.errorColor).withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          AppText(
                            route.isActive ? 'Active Route' : 'Inactive Route',
                            fontSize: 12,
                            color: route.isActive ? AppColors.successColor : AppColors.errorColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // --- Route Summary Card ---
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                borderRadius: 0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Route Summary', fontSize: 16, fontWeight: FontWeight.w700),
                    const SizedBox(height: 20),
                    _buildDetailItem(Iconsax.location5, 'Origin', route.origin),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(indent: 32, thickness: 0.5, color: AppColors.slate200),
                    ),
                    _buildDetailItem(Iconsax.location, 'Destination', route.destination),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(indent: 32, thickness: 0.5, color: AppColors.slate200),
                    ),
                    _buildDetailItem(Iconsax.map, 'Total Distance', '${route.distanceKm} km'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(indent: 32, thickness: 0.5, color: AppColors.slate200),
                    ),
                    _buildDetailItem(Iconsax.clock, 'Est. Duration', route.estimatedTime),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Detailed Waypoints Card ---
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                borderRadius: 0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Detailed Waypoints', fontSize: 16, fontWeight: FontWeight.w700),
                    const SizedBox(height: 24),
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
              
              const SizedBox(height: 24),

              // --- Schedules Card ---
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                borderRadius: 0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Schedules & Frequency', fontSize: 16, fontWeight: FontWeight.w700),
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Iconsax.clock, size: 18, color: AppColors.primaryColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const AppText('Time Slot', fontSize: 11, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
                                      AppText(
                                        '${s['departure_time'] ?? s['start_time'] ?? 'N/A'} - ${s['arrival_time'] ?? s['end_time'] ?? 'N/A'}',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate200.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Iconsax.calendar, size: 18, color: AppColors.textColorSecondary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const AppText('Frequency', fontSize: 11, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
                                      AppText(
                                        s['days'] is List ? (s['days'] as List).join(', ') : (s['days']?.toString() ?? 'Daily'),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorPrimary.withOpacity(0.8),
                                      ),
                                    ],
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
              
              const SizedBox(height: 24),

              // --- Assigned Bus Card ---
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                borderRadius: 0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Assigned Bus', fontSize: 16, fontWeight: FontWeight.w700),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Iconsax.bus,
                                  color: AppColors.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppText(
                                      'DL-1CA-1234',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textColorPrimary,
                                    ),
                                    const SizedBox(height: 4),
                                    const AppText(
                                      'Tata Ultra AC • 45 Seater',
                                      fontSize: 12,
                                      color: AppColors.textColorSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildBusDetailItem('Model Year', '2023'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildBusDetailItem('Fuel Type', 'Diesel'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildBusDetailItem('Last Service', '15 Jan 2026'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildBusDetailItem('Next Service', '15 Apr 2026'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Change Bus Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final route = controller.routes.firstWhere((r) => r.id == routeId, orElse: () => Get.arguments as RouteModel);
                          Get.toNamed(RouteHelper.getAssignRouteRoute(), arguments: route);
                        },
                        icon: const Icon(Iconsax.refresh, size: 18),
                        label: const AppText(
                          'Change Bus',
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
                    
                    const SizedBox(height: 24),
                    
                    // Assigned Driver Section
                    const AppText('Assigned Driver', fontSize: 14, fontWeight: FontWeight.w700),
                    const SizedBox(height: 12),
                    
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
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.user,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppText(
                                      'Rajesh Kumar',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textColorPrimary,
                                    ),
                                    const SizedBox(height: 4),
                                    const AppText(
                                      '+91 98765 43210',
                                      fontSize: 12,
                                      color: AppColors.textColorSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const AppText(
                                  'Available',
                                  fontSize: 10,
                                  color: AppColors.successColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDriverDetailItem('License No.', 'DL-1420110012345'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDriverDetailItem('Experience', '8 Years'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDriverDetailItem('License Expiry', '25 Dec 2027'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDriverDetailItem('Rating', '4.8 ⭐'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Change Driver Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final route = controller.routes.firstWhere((r) => r.id == routeId, orElse: () => Get.arguments as RouteModel);
                          Get.toNamed(RouteHelper.getAssignRouteDriver(), arguments: route);
                        },
                        icon: const Icon(Iconsax.user_edit, size: 18),
                        label: const AppText(
                          'Change Driver',
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
            ],
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

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor.withOpacity(0.7)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label, fontSize: 12, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
              const SizedBox(height: 2),
              AppText(value, fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textColorPrimary),
            ],
          ),
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
