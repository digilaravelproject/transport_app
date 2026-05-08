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

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  late VehicleModel vehicle;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    vehicle = (args is Map) ? args['vehicle'] : (args as VehicleModel? ?? controller.vehicles.first);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    final updated = await controller.fetchVehicleDetails(vehicle.id);
    if (updated != null) {
      setState(() {
        vehicle = updated;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Vehicle Details',
        subtitle: vehicle.vehicleNumber,
        trailing: IconButton(
          icon: const Icon(Iconsax.edit, color: AppColors.primaryColor, size: 20),
          onPressed: () async {
            await Get.toNamed(RouteHelper.getEditVehicleRoute(), arguments: vehicle);
            _loadDetails();
          },
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(vehicle),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Maintenance Summary'),
                  _buildMaintenanceGrid(vehicle),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Payment Ledger (Khata)'),
                  _buildPaymentLedger(vehicle),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Compliance Documents'),
                  _buildDocumentsPreview(vehicle),
                  const SizedBox(height: 32),
                  AppButton.outline(
                    text: 'Maintenance History',
                    onPressed: () => Get.toNamed(RouteHelper.getMaintenanceHistoryRoute(), arguments: vehicle),
                  ),
                ],
              ),
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
                  AppText('Model Year: ${vehicle.modelYear ?? vehicle.year} • ${vehicle.capacity} Seats', 
                    style: AppTextStyle.body, color: AppColors.textColorSecondary),
                ],
              ),
              AppStatusChip(status: vehicle.status.name.capitalizeFirst!),
            ],
          ),
          const Divider(height: 32),
          _buildPriceSummaryBox(vehicle),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.build_rounded, 'Last Service', 
            vehicle.lastServiceDate != null 
              ? '${vehicle.lastServiceDate!.day}/${vehicle.lastServiceDate!.month}/${vehicle.lastServiceDate!.year}'
              : 'Never'),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryBox(VehicleModel vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Seats', '${vehicle.capacity}'),
          _buildVerticalDivider(),
          _buildInfoItem('Price/KM', '₹${vehicle.perKmPrice}'),
          _buildVerticalDivider(),
          _buildInfoItem('AC Extra', '₹${vehicle.acPricePerKm}'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        AppText(label, fontSize: 12, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
        const SizedBox(height: 4),
        AppText(value, fontSize: 16, color: AppColors.primaryColor, fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.primaryColor.withValues(alpha: 0.2),
    );
  }


  Widget _buildMaintenanceGrid(VehicleModel vehicle) {
    return Column(
      children: [
        // View History Section
        Row(
          children: [
            Expanded(child: _buildLogCard('Fuel', Iconsax.gas_station, Colors.orange, RouteHelper.getFuelHistoryRoute(), vehicle)),
            const SizedBox(width: 10),
            Expanded(child: _buildLogCard('Service', Iconsax.setting_2, Colors.blue, RouteHelper.getServiceHistoryRoute(), vehicle)),
            const SizedBox(width: 10),
            Expanded(child: _buildLogCard('Repair', Iconsax.command, Colors.red, RouteHelper.getRepairHistoryRoute(), vehicle)),
          ],
        ),
        const SizedBox(height: 16),
        // Quick Actions Section
        Row(
          children: [
            Expanded(child: _buildAddButton('Fuel', Colors.orange, RouteHelper.getFuelEntryRoute(), vehicle)),
            const SizedBox(width: 10),
            Expanded(child: _buildAddButton('Service', Colors.blue, RouteHelper.getServiceEntryRoute(), vehicle)),
            const SizedBox(width: 10),
            Expanded(child: _buildAddButton('Repair', Colors.red, RouteHelper.getRepairEntryRoute(), vehicle)),
          ],
        ),
      ],
    );
  }

  Widget _buildLogCard(String label, IconData icon, Color color, String route, VehicleModel vehicle) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      onTap: () => Get.toNamed(route, arguments: vehicle),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          AppText('$label Logs', 
            style: AppTextStyle.body, 
            fontSize: 11, 
            fontWeight: FontWeight.w700, 
            textAlign: TextAlign.center,
            color: AppColors.textColorPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, Color color, String route, VehicleModel vehicle) {
    return InkWell(
      onTap: () => Get.toNamed(route, arguments: vehicle),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.add_circle, color: color, size: 14),
            const SizedBox(width: 6),
            AppText('Add', 
              style: AppTextStyle.body, 
              fontSize: 11, 
              color: color, 
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentLedger(VehicleModel vehicle) {
    return Obx(() {
      final spent = controller.totalMaintenanceSpent;
      final paid = controller.totalMaintenancePaid;
      final due = controller.totalMaintenanceDue;

      return AppCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildLedgerStat('Total', spent, AppColors.successColor, Iconsax.receive_square_2),
                ),
                Container(width: 1, height: 40, color: AppColors.slate200),
                Expanded(
                  child: _buildLedgerStat('Pay', paid, AppColors.errorColor, Iconsax.send_sqaure_2),
                ),
                Container(width: 1, height: 40, color: AppColors.slate200),
                Expanded(
                  child: _buildLedgerStat('Due', due, AppColors.indigo500, Iconsax.info_circle),
                ),
              ],
            ),
            if (due > 0) ...[
              const Divider(height: 32),
              Row(
                children: [
                  const Icon(Iconsax.danger, color: AppColors.errorColor, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: AppText('You have pending payments to garages',
                        style: AppTextStyle.caption, color: AppColors.errorColor, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(RouteHelper.getRepairHistoryRoute(), arguments: vehicle),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                    child: const AppText('View Dues',
                        color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildLedgerStat(String label, double value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 18),
        const SizedBox(height: 8),
        AppText('₹ ${value.toStringAsFixed(0)}',
            style: AppTextStyle.body, fontWeight: FontWeight.bold, color: color, fontSize: 13),
        const SizedBox(height: 2),
        AppText(label, style: AppTextStyle.caption, fontSize: 10, color: AppColors.textColorHint),
      ],
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
