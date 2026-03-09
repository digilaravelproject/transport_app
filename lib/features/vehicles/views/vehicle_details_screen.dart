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
import '../../../routes/route_helper.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';

class VehicleDetailsScreen extends GetView<VehicleController> {
  const VehicleDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VehicleModel vehicle = Get.arguments ?? controller.vehicles.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Vehicle Details',
        subtitle: vehicle.vehicleNumber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(vehicle),
            const SizedBox(height: 24),
            _buildSectionTitle('Assigned Driver'),
            _buildDriverCard(vehicle),
            const SizedBox(height: 24),
            _buildSectionTitle('Maintenance Summary'),
            _buildMaintenanceGrid(vehicle),
            const SizedBox(height: 24),
            _buildSectionTitle('Compliance Documents'),
            _buildDocumentsPreview(vehicle),
            const SizedBox(height: 32),
            AppButton(
              text: 'Edit Vehicle',
              onPressed: () => Get.toNamed(RouteHelper.getEditVehicleRoute(), arguments: vehicle),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Maintenance History',
              onPressed: () => Get.toNamed(RouteHelper.getMaintenanceHistoryRoute(), arguments: vehicle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(VehicleModel vehicle) {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(vehicle.vehicleNumber, style: AppTextStyle.heading, fontSize: 20),
                  const SizedBox(height: 4),
                  AppText('${vehicle.type} • ${vehicle.capacity} Seats', 
                    style: AppTextStyle.body, color: AppColors.textColorSecondary),
                ],
              ),
              AppStatusChip(status: vehicle.status.name.capitalizeFirst!),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(Iconsax.calendar_1, 'Model Year', vehicle.year),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.build_rounded, 'Last Service', 
            vehicle.lastServiceDate != null 
              ? '${vehicle.lastServiceDate!.day}/${vehicle.lastServiceDate!.month}/${vehicle.lastServiceDate!.year}'
              : 'Never'),
        ],
      ),
    );
  }

  Widget _buildDriverCard(VehicleModel vehicle) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Iconsax.user, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(vehicle.driverName ?? 'Unassigned', style: AppTextStyle.body, fontWeight: FontWeight.w600),
              AppText('Primary Driver', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            ],
          ),
          const Spacer(),
          if (vehicle.driverName != null)
            IconButton(
              icon: const Icon(Iconsax.call, color: AppColors.successColor, size: 20),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceGrid(VehicleModel vehicle) {
    final items = [
      {'label': 'Fuel History', 'icon': Icons.local_gas_station_rounded, 'route': RouteHelper.getFuelHistoryRoute()},
      {'label': 'Service logs', 'icon': Iconsax.setting_2, 'route': RouteHelper.getServiceHistoryRoute()},
      {'label': 'Repair History', 'icon': Icons.build_circle_rounded, 'route': RouteHelper.getRepairHistoryRoute()},
      {'label': 'Add Fuel', 'icon': Iconsax.add, 'route': RouteHelper.getFuelEntryRoute()},
      {'label': 'Add Service', 'icon': Iconsax.add, 'route': RouteHelper.getServiceEntryRoute()},
      {'label': 'Add Repair', 'icon': Iconsax.add, 'route': RouteHelper.getRepairEntryRoute()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onTap: () => Get.toNamed(items[index]['route'] as String, arguments: vehicle),
          child: Row(
            children: [
              Icon(items[index]['icon'] as IconData, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(items[index]['label'] as String, 
                  style: AppTextStyle.body, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentsPreview(VehicleModel vehicle) {
    return AppCard(
      onTap: () => Get.toNamed(RouteHelper.getVehicleDocumentsRoute(), arguments: vehicle),
      child: Row(
        children: [
          const Icon(Icons.folder_copy_rounded, color: AppColors.warningColor),
          const SizedBox(width: 12),
          const Expanded(
            child: AppText('View RC, Insurance & Permits', style: AppTextStyle.body, fontWeight: FontWeight.w500),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textColorHint),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textColorHint),
        const SizedBox(width: 10),
        AppText('$label: ', style: AppTextStyle.body, color: AppColors.textColorSecondary),
        AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.w600),
      ],
    );
  }
}
