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
    if (Get.arguments == null && controller.routes.isEmpty) {
        return const AppScaffold(appBar: AppHeader(title: 'Route Details'), body: Center(child: Text("No route selected")));
    }
    final RouteModel route = Get.arguments ?? controller.routes.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Route Details',
        rightWidget: IconButton(
          icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
          onPressed: () {},
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AppButton(
            text: 'Assign Bus to Route',
            onPressed: () => Get.toNamed(RouteHelper.getAssignRouteRoute(), arguments: route),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.route_rounded,
                      color: AppColors.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppText(route.routeName, style: AppTextStyle.heading, fontSize: 24, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: route.isActive ? AppColors.successColor.withOpacity(0.1) : AppColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      route.isActive ? 'Active Route' : 'Inactive Route',
                      style: AppTextStyle.caption,
                      color: route.isActive ? AppColors.successColor : AppColors.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Route Summary', style: AppTextStyle.subheading),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildDetailRow('Origin', route.origin),
                  _buildDetailRow('Destination', route.destination),
                  _buildDetailRow('Total Distance', '${route.distanceKm} km'),
                  _buildDetailRow('Est. Duration', route.estimatedTime),
                ],
              ),
            ),
             const SizedBox(height: 24),
             AppCard(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    AppText('Waypoints (${route.viaStops.length + 2})', style: AppTextStyle.subheading),
                    const SizedBox(height: 16),
                    _buildTimelineStop(route.origin, true, false),
                    for (int i = 0; i < route.viaStops.length; i++)
                       _buildTimelineStop(route.viaStops[i], false, false),
                    _buildTimelineStop(route.destination, false, true),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary),
          ),
          Expanded(
            flex: 3,
            child: AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.bold, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStop(String name, bool isFirst, bool isLast) {
    Color nodeColor = isFirst ? AppColors.primaryColor : (isLast ? AppColors.errorColor : AppColors.textColorSecondary);
    IconData nodeIcon = isFirst ? Icons.place_rounded : (isLast ? Icons.outlined_flag_rounded : Icons.circle);
    double iconSize = isFirst || isLast ? 20 : 12;

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.slate300,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                Icon(nodeIcon, color: nodeColor, size: iconSize),
                if (!isLast)
                   Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.slate300,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: AppText(
                name,
                style: AppTextStyle.body,
                fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
