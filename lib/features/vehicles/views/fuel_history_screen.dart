import 'package:flutter/material.dart';
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
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchFuelHistory(vehicle.id),
        child: Column(
          children: [
            _buildSummaryCard(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.fuelHistory.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
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
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final total = controller.fuelHistory.fold(0.0, (sum, item) => sum + item.amount);
      final avg = controller.fuelHistory.isEmpty ? 0.0 : total / controller.fuelHistory.fold(0.0, (sum, item) => sum + item.quantity);
      
      // Calculate monthly cost (current month)
      final now = DateTime.now();
      final monthly = controller.fuelHistory
          .where((e) => e.date.month == now.month && e.date.year == now.year)
          .fold(0.0, (sum, item) => sum + item.amount);

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
          Row(
            children: [
              if (entry.receiptPath != null && entry.receiptPath!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.visibility_rounded, color: AppColors.primaryColor, size: 20),
                  onPressed: () => Get.toNamed(
                    RouteHelper.getDocumentPreviewRoute(),
                    arguments: AppConstants.getFileUrl(entry.receiptPath),
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
    );
  }
}
