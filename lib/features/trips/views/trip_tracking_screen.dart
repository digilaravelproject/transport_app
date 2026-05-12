import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';

class TripTrackingScreen extends GetView<TripController> {
  const TripTrackingScreen({Key? key}) : super(key: key);

  Future<void> _makeCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMap(TripModel trip) async {
    if (trip.pickupAddress == null) return;

    String origin = Uri.encodeComponent(trip.pickupAddress!);
    String destination = "";
    String waypoints = "";

    final points = trip.destinationPoints ?? [];
    if (points.isNotEmpty) {
      destination = Uri.encodeComponent(points.last['name']?.toString() ?? '');
      if (points.length > 1) {
        waypoints = points
            .take(points.length - 1)
            .map((p) => Uri.encodeComponent(p['name']?.toString() ?? ''))
            .join('|');
      }
    } else {
      destination = origin;
    }

    String url = "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination";
    if (waypoints.isNotEmpty) {
      url += "&waypoints=$waypoints";
    }

    final Uri googleMapsUri = Uri.parse(url);
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TripModel trip = (Get.arguments is TripModel) ? Get.arguments : controller.selectedTrip.value!;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Track Trip',
        subtitle: trip.route,
      ),
      body: Column(
        children: [
          // Map Placeholder
          Container(
            height: 300,
            width: double.infinity,
            color: AppColors.slate100,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Horizontal Route Line
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMapPoint('Pickup', trip.pickupAddress ?? ''),
                              ... (trip.destinationPoints ?? []).map((p) => Row(
                                children: [
                                  Container(width: 40, height: 2, color: AppColors.primaryColor.withOpacity(0.3)),
                                  _buildMapPoint(p['type']?.toString().capitalizeFirst ?? 'Point', p['name']?.toString() ?? ''),
                                ],
                              )).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const AppText('Route Overview', color: AppColors.slate400, fontSize: 12),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(heroTag: null,
                    onPressed: () => _openMap(trip),
                    backgroundColor: AppColors.white,
                    child: const Icon(Icons.my_location_rounded, color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAssignedAssets(trip),
                  const SizedBox(height: 24),
                  AppText('Trip Progress', style: AppTextStyle.subheading, fontSize: 16),
                  const SizedBox(height: 16),
                  _buildVerticalTimeline(trip),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Open Map for Navigation',
                    icon: const Icon(Icons.near_me_rounded, size: 18),
                    onPressed: () => _openMap(trip),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedAssets(TripModel trip) {
    if (trip.assignedDrivers.isEmpty && trip.assignedVehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Drivers & Vehicles', style: AppTextStyle.subheading, fontSize: 16),
        const SizedBox(height: 12),
        ...trip.assignedDrivers.asMap().entries.map((entry) {
          final int idx = entry.key;
          final driver = entry.value;
          final vehicle = trip.assignedVehicles.length > idx ? trip.assignedVehicles[idx] : null;
          
          final String dName = driver['name']?.toString() ?? 'N/A';
          final String dPhone = driver['phone']?.toString() ?? '';
          final String vNum = vehicle?['registration_number']?.toString() ?? 'N/A';
          final String vType = vehicle?['type']?.toString() ?? trip.vehicleType;

          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Iconsax.user, color: AppColors.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(dName, style: AppTextStyle.body, fontWeight: FontWeight.w600),
                      AppText("$vType - $vNum", style: AppTextStyle.caption, fontSize: 11),
                      if (dPhone.isNotEmpty)
                        AppText(dPhone, style: AppTextStyle.caption, fontSize: 10),
                    ],
                  ),
                ),
                if (dPhone.isNotEmpty)
                  IconButton(
                    icon: const Icon(Iconsax.call, color: AppColors.primaryColor, size: 20),
                    onPressed: () => _makeCall(dPhone),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildVerticalTimeline(TripModel trip) {
    List<Widget> children = [];
    
    // Pickup Point
    children.add(_buildTimelineStep(
      'Pickup Point', 
      trip.pickupAddress ?? 'N/A', 
      true, 
      true,
      isCurrent: false,
    ));

    // Destination Points
    final points = trip.destinationPoints ?? [];
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final bool isLast = i == points.length - 1;
      
      children.add(_buildTimelineStep(
        point['type']?.toString().capitalizeFirst ?? 'Point',
        point['name']?.toString() ?? 'N/A',
        false,
        false,
        isLast: isLast,
        isCurrent: false,
      ));
    }

    return Column(children: children);
  }

  Widget _buildTimelineStep(String title, String sub, bool isDone, bool isFirst, {bool isLast = false, bool isCurrent = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 2,
              height: 20,
              color: isFirst ? Colors.transparent : (isDone ? AppColors.successColor : AppColors.slate200),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primaryColor : (isDone ? AppColors.successColor : AppColors.slate300),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrent ? Iconsax.location : (isDone ? Iconsax.tick_circle : Icons.circle),
                size: 12,
                color: AppColors.white,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: isLast ? Colors.transparent : (isDone ? AppColors.successColor : AppColors.slate200),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              AppText(
                title,
                style: AppTextStyle.body,
                fontWeight: isCurrent ? FontWeight.bold : (isDone ? FontWeight.w600 : FontWeight.normal),
                color: isCurrent ? AppColors.primaryColor : AppColors.textColorPrimary,
              ),
              AppText(sub, style: AppTextStyle.caption),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPoint(String title, String address) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: Icon(
            title.toLowerCase() == 'pickup' ? Iconsax.location : Icons.circle, 
            size: 16, 
            color: AppColors.primaryColor
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: AppText(
            address, 
            fontSize: 10, 
            align: TextAlign.center, 
            maxLines: 2, 
            overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }
}
