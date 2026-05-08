import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';
import '../../../routes/route_helper.dart';
import '../domain/models/service_record_model.dart';
import '../../../core/widgets/app_empty_state.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  late VehicleModel vehicle;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    vehicle = (args is Map) ? args['vehicle'] : (args as VehicleModel? ?? controller.vehicles.first);
    
    // Fetch fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchServiceHistory(vehicle.id);
    });
  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      appBar: AppHeader(
        title: 'Service History',
        subtitle: vehicle.vehicleNumber,
        trailing: _buildAddHeaderButton(
          color: AppColors.primaryColor,
          onTap: () => Get.toNamed('/service-entry', arguments: vehicle),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchServiceHistory(vehicle.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  AppFilterChip(
                  label: 'All', 
                  isSelected: controller.selectedServiceFilter.value == 'All' && controller.serviceStartDate.value == null, 
                  onTap: () => controller.setServiceFilter('All'),
                ),
                  const SizedBox(width: 8),
                  AppFilterChip(label: 'Pending', isSelected: controller.selectedServiceFilter.value == 'Pending', onTap: () => controller.setServiceFilter('Pending')),
                  const SizedBox(width: 8),
                  AppFilterChip(label: 'Paid', isSelected: controller.selectedServiceFilter.value == 'Paid', onTap: () => controller.setServiceFilter('Paid')),
                  const SizedBox(width: 8),
                  AppFilterChip(
                    label: controller.serviceStartDate.value == null 
                      ? 'Date' 
                      : '${controller.serviceStartDate.value!.day}/${controller.serviceStartDate.value!.month} - ${controller.serviceEndDate.value!.day}/${controller.serviceEndDate.value!.month}',
                    isSelected: controller.serviceStartDate.value != null,
                    showIcon: true,
                    onTap: () async {
                      if (controller.serviceStartDate.value != null) {
                        controller.clearServiceDateRange();
                      } else {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.primaryColor,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: AppColors.textColorPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (range != null) {
                          controller.setServiceDateRange(range.start, range.end);
                        }
                      }
                    },
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final history = controller.filteredServiceHistory;
                if (history.isEmpty) {
                  return AppEmptyState(
                    title: 'No Service Records',
                    subtitle: 'Start by adding your first service entry for this vehicle.',
                    icon: Iconsax.setting_2,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    return _buildServiceCard(record, vehicle);
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Obx(() {
        final totalBill = controller.totalServiceAmount.value;
        final totalPaid = controller.paidServiceAmount.value;
        final totalPending = controller.dueServiceAmount.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryItem('Total', '₹ ${totalBill.toStringAsFixed(0)}', Iconsax.receive_square_2,
                color: AppColors.successColor),
            _buildSummaryItem('Pay', '₹ ${totalPaid.toStringAsFixed(0)}', Iconsax.send_sqaure_2,
                color: AppColors.errorColor),
            _buildSummaryItem('Due', '₹ ${totalPending.toStringAsFixed(0)}', Iconsax.info_circle,
                color: totalPending > 0 ? AppColors.indigo500 : AppColors.successColor),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.primaryColor, size: 20),
        const SizedBox(height: 8),
        AppText(value, 
          style: AppTextStyle.body, 
          fontWeight: FontWeight.bold,
          color: color,
        ),
        AppText(label, style: AppTextStyle.caption, fontSize: 10, color: AppColors.textColorHint),
      ],
    );
  }

  Widget _buildServiceCard(ServiceRecord record, VehicleModel vehicle) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => Get.toNamed('/service-payment-history', arguments: {
        'record': record,
        'vehicle': vehicle,
        'type': 'Service',
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(record.type, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Iconsax.location, size: 12, color: AppColors.textColorHint),
                        const SizedBox(width: 4),
                        Expanded(child: AppText(record.workshop, style: AppTextStyle.caption, color: AppColors.textColorSecondary, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 12, color: AppColors.textColorHint),
                      const SizedBox(width: 4),
                      AppText('${record.date.day}/${record.date.month}/${record.date.year}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                    ],
                  ),
                  if (record.pendingAmount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.errorColorAccent, borderRadius: BorderRadius.circular(4)),
                      child: const AppText('Pending', style: AppTextStyle.caption, fontSize: 10, color: AppColors.errorColor, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  if (record.billUrl != null && record.billUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => Get.toNamed('/document-preview', arguments: record.billUrl),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.eye, size: 16, color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textColorHint),
                ],
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniSummaryItem('Total', '₹${record.totalBill.toStringAsFixed(0)}', Iconsax.receive_square_2, color: AppColors.secondaryColor),
              _buildMiniSummaryItem('Pay', '₹${record.paidAmount.toStringAsFixed(0)}', Iconsax.send_sqaure_2, color: AppColors.errorColor),
              _buildMiniSummaryItem('Due', '₹${record.pendingAmount.toStringAsFixed(0)}', Iconsax.info_circle, color: record.pendingAmount > 0 ? AppColors.indigo500 : AppColors.successColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummaryItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color ?? AppColors.primaryColor, size: 12),
            const SizedBox(width: 4),
            AppText(value, style: AppTextStyle.caption, fontWeight: FontWeight.bold, color: color),
          ],
        ),
        const SizedBox(height: 2),
        AppText(label, style: AppTextStyle.caption, fontSize: 9, color: AppColors.textColorHint),
      ],
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
