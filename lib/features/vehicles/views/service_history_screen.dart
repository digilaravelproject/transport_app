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

class ServiceHistoryScreen extends GetView<VehicleController> {
  const ServiceHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VehicleModel vehicle = Get.arguments ?? controller.vehicles.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Service History',
        subtitle: vehicle.vehicleNumber,
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: Obx(() {
              if (controller.serviceHistory.isEmpty) {
                return const Center(child: AppText('No service records found', style: AppTextStyle.body));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.serviceHistory.length,
                itemBuilder: (context, index) {
                  final record = controller.serviceHistory[index];
                  return _buildServiceCard(record);
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('Total Cost', '₹ 45,850', Iconsax.card),
          Container(width: 1, height: 40, color: AppColors.slate200),
          _buildSummaryItem('Last Service', '30 Days ago', Icons.build_rounded),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(height: 8),
        AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.bold),
        AppText(label, style: AppTextStyle.caption, fontSize: 10, color: AppColors.textColorHint),
      ],
    );
  }

  Widget _buildServiceCard(ServiceRecord record) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(record.type, style: AppTextStyle.body, fontWeight: FontWeight.bold),
              AppText('₹ ${record.cost}', style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Iconsax.calendar_1, size: 12, color: AppColors.textColorHint),
              const SizedBox(width: 4),
              AppText('${record.date.day}/${record.date.month}/${record.date.year}', 
                style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              const SizedBox(width: 12),
              const Icon(Iconsax.location, size: 12, color: AppColors.textColorHint),
              const SizedBox(width: 4),
              Expanded(child: AppText(record.workshop, style: AppTextStyle.caption, color: AppColors.textColorSecondary, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}
