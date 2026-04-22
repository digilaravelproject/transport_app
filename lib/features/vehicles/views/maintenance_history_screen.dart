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

class MaintenanceHistoryScreen extends GetView<VehicleController> {
  const MaintenanceHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VehicleModel vehicle = Get.arguments ?? controller.vehicles.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Maintenance Timeline',
        subtitle: vehicle.vehicleNumber,
      ),
      body: Obx(() {
        // Combine fuel and service for timeline
        final List<Map<String, dynamic>> timeline = [
          ...controller.fuelHistory.map((e) => {'date': e.date, 'type': 'Fuel', 'label': e.station, 'cost': e.amount, 'icon': Icons.local_gas_station_rounded}),
          ...controller.serviceHistory.map((e) => {
                'date': e.date,
                'type': 'Service',
                'label': e.type,
                'cost': e.totalBill,
                'icon': Iconsax.setting_2
              }),
          ...controller.repairHistory.map((e) => {
                'date': e.date,
                'type': 'Repair',
                'label': e.type,
                'cost': e.totalBill,
                'icon': Icons.build_circle_rounded
              }),
        ];
        timeline.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

        if (timeline.isEmpty) {
          return const Center(child: AppText('No maintenance history available', style: AppTextStyle.body));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: timeline.length,
          itemBuilder: (context, index) {
            final item = timeline[index];
            return _buildTimelineItem(item, index == timeline.length - 1);
          },
        );
      }),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast) {
    final DateTime date = item['date'] as DateTime;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Icon(item['icon'] as IconData, color: AppColors.primaryColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
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
                    AppText(item['type'] as String, style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    AppText('₹ ${item['cost']}', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(item['label'] as String, style: AppTextStyle.body, fontSize: 13),
                const SizedBox(height: 8),
                AppText('${date.day}/${date.month}/${date.year}', style: AppTextStyle.caption, color: AppColors.textColorHint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
