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
import '../domain/models/fuel_entry_model.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_empty_state.dart';

class FuelHistoryScreen extends StatefulWidget {
  const FuelHistoryScreen({Key? key}) : super(key: key);

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  late VehicleModel vehicle;

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments as VehicleModel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFuelHistory(vehicle.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Fuel History',
        subtitle: vehicle.vehicleNumber,
        trailing: _buildAddHeaderButton(
          color: Colors.orange,
          onTap: () => Get.toNamed(RouteHelper.getFuelEntryRoute(), arguments: vehicle),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchFuelHistory(vehicle.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: AppText(
                'Fuel Transactions',
                style: AppTextStyle.subheading,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.fuelHistory.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.fuelHistory.isEmpty) {
                  return AppEmptyState(
                    title: 'No Fuel Records',
                    subtitle: 'Start by adding your first fuel entry for this vehicle.',
                    icon: Iconsax.gas_station,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final total = controller.totalFuelExpense.value;
      final monthly = controller.monthlyFuelCost.value;
      final avg = controller.avgFuelPrice.value;

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
            AppText('₹ ${total.toStringAsFixed(2)}', style: AppTextStyle.heading, fontSize: 24, color: AppColors.white),
            const Divider(height: 32, color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryStat('Monthly Cost', '₹ ${monthly.toStringAsFixed(0)}'),
                _buildSummaryStat('Avg / Ltr', '₹ ${avg.toStringAsFixed(1)}'),
              ],
            ),
          ],
        ),
      );
    });
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

  Widget _buildFuelCard(FuelEntryModel entry) {
    return GestureDetector(
      onTap: () => Get.toNamed('/document-preview', arguments: entry.receiptPath),
      child: AppCard(
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
            Row(
              children: [
                if (entry.receiptPath != null && entry.receiptPath!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => Get.toNamed('/document-preview', arguments: entry.receiptPath),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.eye, size: 16, color: Colors.orange),
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText('₹ ${entry.amount.toStringAsFixed(1)}', style: AppTextStyle.body, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                    AppText('${entry.quantity.toStringAsFixed(1)} Ltr', style: AppTextStyle.caption),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddHeaderButton({required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.add_circle, color: color, size: 14),
            const SizedBox(width: 4),
            AppText('Add', 
              fontSize: 12, 
              color: color, 
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}
