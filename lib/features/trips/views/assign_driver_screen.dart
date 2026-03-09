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

class AssignDriverScreen extends GetView<TripController> {
  const AssignDriverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock drivers for selection
    final drivers = [
      {'name': 'Rajesh Kumar', 'phone': '+91 9876543210', 'exp': '8 Years', 'status': 'Available'},
      {'name': 'Suresh Patil', 'phone': '+91 8765432109', 'exp': '12 Years', 'status': 'On Trip'},
      {'name': 'Karthik Rao', 'phone': '+91 7654321098', 'exp': '5 Years', 'status': 'Available'},
      {'name': 'Amit Singh', 'phone': '+91 6543210987', 'exp': '10 Years', 'status': 'Available'},
    ];

    return AppScaffold(
      appBar: const AppHeader(title: 'Assign Driver'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search driver name...',
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
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final d = drivers[index];
                final bool isAvailable = d['status'] == 'Available';
                
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(Iconsax.user, color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(d['name']!, style: AppTextStyle.subheading, fontSize: 16),
                            AppText('Exp: ${d['exp']} • ${d['phone']}', style: AppTextStyle.caption),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppStatusChip(status: d['status']!),
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
