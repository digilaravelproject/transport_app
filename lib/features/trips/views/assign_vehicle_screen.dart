import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../controllers/trip_controller.dart';

class AssignVehicleScreen extends GetView<TripController> {
  const AssignVehicleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock vehicles for selection
    final vehicles = [
      {'no': 'DL 01 AB 1234', 'type': 'Luxury Bus', 'capacity': '45 Seater', 'status': 'Available'},
      {'no': 'DL 01 CD 5678', 'type': 'Mini Bus', 'capacity': '25 Seater', 'status': 'Available'},
      {'no': 'HR 55 XY 9012', 'type': 'Luxury Bus', 'capacity': '45 Seater', 'status': 'On Trip'},
      {'no': 'UP 14 ZE 3456', 'type': 'Innova', 'capacity': '7 Seater', 'status': 'Available'},
    ];

    return AppScaffold(
      appBar: const AppHeader(title: 'Assign Vehicle'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search vehicle number or type...',
                prefixIcon: const Icon(Iconsax.search_normal),
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final v = vehicles[index];
                final bool isAvailable = v['status'] == 'Available';
                
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          v['type'] == 'Innova' ? Icons.directions_car_rounded : Iconsax.bus,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(v['no']!, style: AppTextStyle.subheading, fontSize: 16),
                            AppText('${v['type']} • ${v['capacity']}', style: AppTextStyle.caption),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppStatusChip(status: v['status']!),
                          const SizedBox(height: 8),
                          if (isAvailable)
                            AppButton(
                              text: 'Assign',
                              width: 70,
                              height: 30,
                              fontSize: 12,
                              onPressed: () => Get.back(),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
