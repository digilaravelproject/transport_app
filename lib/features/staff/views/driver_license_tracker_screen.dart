import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../domain/models/staff_model.dart';
import '../controllers/staff_controller.dart';

class DriverLicenseTrackerScreen extends GetView<StaffController> {
  const DriverLicenseTrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'License Tracker',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search Driver Name',
              onChanged: (v) {},
            ),
          ),
          Expanded(
            child: Obx(() {
              final drivers = controller.staffList.where((s) => s.role == StaffRole.driver).toList();
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  // Mock expiry data
                  final expiryDate = DateTime.now().add(Duration(days: index == 0 ? -5 : (index == 1 ? 15 : 180)));
                  return _LicenseCard(driver: driver, expiryDate: expiryDate);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LicenseCard extends StatelessWidget {
  final StaffModel driver;
  final DateTime expiryDate;
  
  const _LicenseCard({required this.driver, required this.expiryDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysToExpiry = expiryDate.difference(now).inDays;
    
    Color statusColor;
    String statusText;
    
    if (daysToExpiry < 0) {
      statusColor = AppColors.errorColor;
      statusText = 'Expired';
    } else if (daysToExpiry <= 30) {
      statusColor = Colors.orange;
      statusText = 'Expiring in $daysToExpiry days';
    } else {
      statusColor = AppColors.successColor;
      statusText = 'Valid';
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(Icons.badge_rounded, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(driver.name, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText('License No: DL-${driver.id.toString().substring(0, 8)}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText('Expiry: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}', style: AppTextStyle.caption),
              const SizedBox(height: 4),
              AppText(statusText, style: AppTextStyle.caption, color: statusColor, fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }
}
