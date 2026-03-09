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

class TripSummaryScreen extends GetView<TripController> {
  const TripSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments ?? controller.trips.first;

    return AppScaffold(
      appBar: const AppHeader(title: 'Trip Summary'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 24),
            _buildSummaryStats(),
            const SizedBox(height: 24),
            _buildDetailSection(trip),
            const SizedBox(height: 32),
            AppButton(
              text: 'Back to Trip List',
              onPressed: () => Get.offAllNamed('/dashboard'),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'View Invoice',
              onPressed: () => Get.toNamed('/trip-invoice', arguments: trip),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.tick_circle, color: AppColors.successColor, size: 64),
        ),
        const SizedBox(height: 16),
        const AppText('Trip Completed Successfully!', style: AppTextStyle.heading, fontSize: 20),
        const SizedBox(height: 4),
        AppText('12th Oct 2023 • Delhi to Jaipur', style: AppTextStyle.caption),
      ],
    );
  }

  Widget _buildSummaryStats() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('KMs Run', '540 KM', Icons.speed_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Duration', '2 Days', Icons.timer_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Fuel Used', '65 Ltr', Icons.local_gas_station_rounded)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(height: 8),
          AppText(value, style: AppTextStyle.subheading, fontSize: 14),
          AppText(label, style: AppTextStyle.caption, fontSize: 10),
        ],
      ),
    );
  }

  Widget _buildDetailSection(TripModel trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Financial Overview'),
        AppCard(
          child: Column(
            children: [
              _buildDetailRow('Total Revenue', '₹ 25,000', isPositive: true),
              _buildDetailRow('Total Expenses', '₹ 8,450', isPositive: false),
              const Divider(height: 32),
              _buildDetailRow('Net Profit', '₹ 16,550', isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: AppText(
        title,
        style: AppTextStyle.subheading,
        fontSize: 14,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPositive = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: AppTextStyle.body),
          AppText(
            value,
            style: AppTextStyle.body,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isPositive ? AppColors.successColor : (isBold ? AppColors.textColorPrimary : AppColors.errorColor),
          ),
        ],
      ),
    );
  }
}
