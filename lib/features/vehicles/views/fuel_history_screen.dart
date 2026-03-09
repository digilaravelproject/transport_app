import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';

class FuelHistoryScreen extends GetView<VehicleController> {
  const FuelHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VehicleModel vehicle = Get.arguments ?? controller.vehicles.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Fuel History',
        subtitle: vehicle.vehicleNumber,
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: Obx(() {
              if (controller.fuelHistory.isEmpty) {
                return const Center(child: AppText('No fuel records found', style: AppTextStyle.body));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.fuelHistory.length,
                itemBuilder: (context, index) {
                  final entry = controller.fuelHistory[index];
                  return _buildFuelCard(entry);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Total Fuel Expense', style: AppTextStyle.caption, color: Colors.white70),
          const SizedBox(height: 4),
          const AppText('₹ 45,850.00', style: AppTextStyle.heading, fontSize: 24, color: AppColors.white),
          const Divider(height: 32, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('Monthly Cost', '₹ 12,400'),
              _buildSummaryStat('Avg / Ltr', '₹ 94.5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.caption, fontSize: 10, color: Colors.white70),
        AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.white),
      ],
    );
  }

  Widget _buildFuelCard(FuelEntry entry) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('${entry.date.day}/${entry.date.month}/${entry.date.year}', 
                style: AppTextStyle.body, fontWeight: FontWeight.bold),
              const SizedBox(height: 4),
              AppText(entry.station, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText('₹ ${entry.amount}', style: AppTextStyle.body, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
              AppText('${entry.quantity} Ltr', style: AppTextStyle.caption),
            ],
          ),
        ],
      ),
    );
  }
}
