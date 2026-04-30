import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';

import '../domain/models/timeline_record_model.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_constants.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  const MaintenanceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceHistoryScreen> createState() => _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  late VehicleModel vehicle;

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments ?? controller.vehicles.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchVehicleTimeline(vehicle.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Maintenance Timeline',
        subtitle: vehicle.vehicleNumber,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchVehicleTimeline(vehicle.id),
        child: Obx(() {
          if (controller.isLoading.value && controller.timelineHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.timelineHistory.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const Center(child: AppText('No maintenance history available', style: AppTextStyle.body)),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.timelineHistory.length,
            itemBuilder: (context, index) {
              final item = controller.timelineHistory[index];
              return _buildTimelineItem(item, index == controller.timelineHistory.length - 1);
            },
          );
        }),
      ),
    );
  }

  Widget _buildTimelineItem(TimelineRecord item, bool isLast) {
    IconData icon;
    String typeLabel;
    
    switch (item.activityType.toLowerCase()) {
      case 'fuel':
        icon = Icons.local_gas_station_rounded;
        typeLabel = 'Fuel';
        break;
      case 'service':
        icon = Iconsax.setting_2;
        typeLabel = 'Service';
        break;
      case 'repair':
        icon = Icons.build_circle_rounded;
        typeLabel = 'Repair';
        break;
      case 'document':
        icon = Iconsax.document;
        typeLabel = 'Document';
        break;
      default:
        icon = Iconsax.info_circle;
        typeLabel = item.activityType.capitalizeFirst ?? 'Activity';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primaryColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 70,
                color: AppColors.slate200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppCard(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(typeLabel, style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    Row(
                      children: [
                        if (item.receiptPath != null && item.receiptPath!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => Get.toNamed(RouteHelper.getDocumentPreviewRoute(), arguments: item.receiptPath),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Iconsax.eye, size: 14, color: AppColors.primaryColor),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (item.amount != null && item.amount! > 0)
                          AppText('₹ ${item.amount!.toStringAsFixed(0)}', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(item.title, style: AppTextStyle.body, fontSize: 13),
                if (item.quantity != null && item.quantity! > 0) ...[
                  const SizedBox(height: 4),
                  AppText('Quantity: ${item.quantity} Ltr', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                ],
                const SizedBox(height: 8),
                AppText('${item.date.day}/${item.date.month}/${item.date.year}', style: AppTextStyle.caption, color: AppColors.textColorHint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
