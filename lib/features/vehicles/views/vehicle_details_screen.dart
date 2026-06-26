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
import '../../../core/constants/app_text_constants.dart';

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
    if (args is String) {
      final intId = int.tryParse(args);
      vehicle = controller.vehicles.firstWhere((v) => v.id == intId, 
        orElse: () => VehicleModel(
          id: intId,
          vehicleNumber: 'Loading...',
          type: '',
          capacity: 0,
          year: '',
          status: VehicleStatus.active,
        )
      );
    } else {
      vehicle = (args is Map) ? args['vehicle'] : (args as VehicleModel? ?? controller.vehicles.first);
    }
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
        title: AppTextConstants.vehicleDetails.tr,
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
                  _buildSectionTitle(AppTextConstants.maintenanceSummary.tr),
                  _buildMaintenanceGrid(vehicle),
                  const SizedBox(height: 24),
                  _buildSectionTitle(AppTextConstants.paymentLedger.tr),
                  _buildPaymentLedger(vehicle),
                  const SizedBox(height: 24),
                  _buildSectionTitle(AppTextConstants.complianceDocuments.tr),
                  _buildDocumentsPreview(vehicle),
                  const SizedBox(height: 32),
                  AppButton.outline(
                    text: AppTextConstants.maintenanceHistory.tr,
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
                  AppText('${AppTextConstants.modelYearLabel.tr}: ${vehicle.modelYear ?? vehicle.year} • ${vehicle.capacity} ${AppTextConstants.seats.tr}', 
                    style: AppTextStyle.body, color: AppColors.textColorSecondary),
                ],
              ),
              AppStatusChip(status: vehicle.status.name),
            ],
          ),
          const Divider(height: 32),
          _buildPriceSummaryBox(vehicle),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.build_rounded, AppTextConstants.lastService.tr, 
            vehicle.lastServiceDate != null 
              ? '${vehicle.lastServiceDate!.day}/${vehicle.lastServiceDate!.month}/${vehicle.lastServiceDate!.year}'
              : AppTextConstants.never.tr),
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
          _buildInfoItem(AppTextConstants.seats.tr, '${vehicle.capacity}'),
          _buildVerticalDivider(),
          _buildInfoItem(AppTextConstants.pricePerKm.tr, '₹${vehicle.perKmPrice}'),
          _buildVerticalDivider(),
          _buildInfoItem(AppTextConstants.acExtra.tr, '₹${vehicle.acPricePerKm}'),
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
            Expanded(child: _buildLogCard(AppTextConstants.fuel.tr, Iconsax.gas_station, Colors.orange, RouteHelper.getFuelHistoryRoute(), vehicle)),
            const SizedBox(width: 10),
            Expanded(child: _buildLogCard(AppTextConstants.service.tr, Iconsax.setting_2, Colors.blue, RouteHelper.getServiceHistoryRoute(), vehicle)),
            const SizedBox(width: 10),
            Expanded(child: _buildLogCard(AppTextConstants.repair.tr, Iconsax.command, Colors.red, RouteHelper.getRepairHistoryRoute(), vehicle)),
          ],
        ),
        const SizedBox(height: 16),
        // Quick Actions Section
        Row(
          children: [
            Expanded(child: _buildAddButton(AppTextConstants.fuel.tr, Colors.orange, RouteHelper.getFuelEntryRoute(), vehicle)),
            const SizedBox(width: 10),
            Expanded(child: _buildAddButton(AppTextConstants.service.tr, Colors.blue, RouteHelper.getServiceEntryRoute(), vehicle)),
            const SizedBox(width: 10),
            Expanded(child: _buildAddButton(AppTextConstants.repair.tr, Colors.red, RouteHelper.getRepairEntryRoute(), vehicle)),
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
          AppText('$label ${AppTextConstants.logs.tr}', 
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
            AppText(AppTextConstants.add.tr, 
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
                  child: _buildLedgerStat(AppTextConstants.total.tr, spent, AppColors.successColor, Iconsax.receive_square_2),
                ),
                Container(width: 1, height: 40, color: AppColors.slate200),
                Expanded(
                  child: _buildLedgerStat(AppTextConstants.collect.tr, paid, AppColors.errorColor, Iconsax.send_sqaure_2),
                ),
                Container(width: 1, height: 40, color: AppColors.slate200),
                Expanded(
                  child: _buildLedgerStat(AppTextConstants.pending.tr, due, AppColors.indigo500, Iconsax.info_circle),
                ),
              ],
            ),
            if (due > 0) ...[
              const Divider(height: 32),
              Row(
                children: [
                  const Icon(Iconsax.danger, color: AppColors.errorColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(AppTextConstants.pendingPaymentsGarages.tr,
                        style: AppTextStyle.caption, color: AppColors.errorColor, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(RouteHelper.getRepairHistoryRoute(), arguments: vehicle),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                    child: AppText(AppTextConstants.viewDues.tr,
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
          Expanded(
            child: AppText(AppTextConstants.viewRcInsurance.tr, style: AppTextStyle.body, fontWeight: FontWeight.w500),
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
