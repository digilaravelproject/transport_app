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
import '../domain/models/service_record_model.dart';

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/service-entry', arguments: vehicle),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                AppFilterChip(label: 'All', isSelected: controller.selectedServiceFilter.value == 'All', onTap: () => controller.setServiceFilter('All')),
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
                return const Center(child: AppText('No service records found', style: AppTextStyle.body));
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
        final totalBill =
            controller.serviceHistory.fold<double>(0.0, (sum, item) => sum + item.totalBill);
        final totalPaid =
            controller.serviceHistory.fold<double>(0.0, (sum, item) => sum + item.paidAmount);
        final totalPending = totalBill - totalPaid;

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
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textColorHint),
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
}
