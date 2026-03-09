import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/corporate_controller.dart';
import '../domain/models/company_model.dart';
import '../../../routes/route_helper.dart';

class CorporateDutyTrackingScreen extends GetView<CorporateController> {
  const CorporateDutyTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Duty Tracking',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          final isCompleted = index % 3 == 0;
          return _DutyTrackingCard(
            companyName: index % 2 == 0 ? 'TCS' : 'Infosys',
            vehicleNo: 'MH 14 AB ${1000 + index}',
            date: DateTime.now().subtract(Duration(days: index)),
            status: isCompleted ? 'Completed' : 'Ongoing',
          );
        },
      ),
    );
  }
}

class _DutyTrackingCard extends StatelessWidget {
  final String companyName;
  final String vehicleNo;
  final DateTime date;
  final String status;

  const _DutyTrackingCard({
    required this.companyName,
    required this.vehicleNo,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    bool isOngoing = status == 'Ongoing';
    bool isCompleted = status == 'Completed';

    Color statusColor = AppColors.textColorSecondary;
    if (isOngoing) statusColor = Colors.orange;
    if (isCompleted) statusColor = AppColors.successColor;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(companyName, style: AppTextStyle.subheading, fontSize: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(status, style: AppTextStyle.caption, color: statusColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Iconsax.bus, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText('Vehicle: $vehicleNo', style: AppTextStyle.body),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.calendar_1, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText('Date: ${date.day}/${date.month}/${date.year}', style: AppTextStyle.body),
            ],
          ),
          if (isOngoing) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar('Duty Marked Completed', 'Duty for $companyName marked as completed.', snackPosition: SnackPosition.BOTTOM);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const AppText('Mark as Completed', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
