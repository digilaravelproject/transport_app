import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';

class TripStatusUpdateScreen extends StatefulWidget {
  const TripStatusUpdateScreen({Key? key}) : super(key: key);

  @override
  State<TripStatusUpdateScreen> createState() => _TripStatusUpdateScreenState();
}

class _TripStatusUpdateScreenState extends State<TripStatusUpdateScreen> {
  TripStatus selectedStatus = TripStatus.ongoing;

  final List<Map<String, dynamic>> statuses = [
    {'status': TripStatus.pending, 'label': 'Trip Scheduled', 'icon': Iconsax.clock},
    {'status': TripStatus.ongoing, 'label': 'Trip Started', 'icon': Icons.play_arrow_rounded},
    {'status': TripStatus.completed, 'label': 'Trip Completed', 'icon': Iconsax.tick_circle},
    {'status': TripStatus.cancelled, 'label': 'Trip Cancelled', 'icon': Icons.cancel_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(title: 'Update Status'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: statuses.map((s) {
                  final bool isSelected = selectedStatus == s['status'];
                  return ListTile(
                    leading: Icon(
                      s['icon'] as IconData,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorHint,
                    ),
                    title: AppText(
                      s['label'] as String,
                      style: AppTextStyle.body,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    trailing: isSelected
                        ? const Icon(Iconsax.tick_circle, color: AppColors.primaryColor)
                        : null,
                    onTap: () => setState(() => selectedStatus = s['status'] as TripStatus),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            AppButton(
              text: 'Update Status',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
