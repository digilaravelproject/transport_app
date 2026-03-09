import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../controllers/reports_controller.dart';
import '../domain/models/report_model.dart';
import '../../../routes/route_helper.dart';

class ReportsDashboardScreen extends GetView<ReportsController> {
  const ReportsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Reports & Analytics',
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: null,
        onPressed: () => _showGenerateReportDialog(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const AppText('Generate Report', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricsGrid(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Generate Specific Reports', style: AppTextStyle.subheading),
              ],
            ),
            const SizedBox(height: 12),
            _buildReportCategoryCards(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Recent Reports', style: AppTextStyle.subheading),
                TextButton(
                  onPressed: () {},
                  child: const AppText('View All', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
               if (controller.recentReports.isEmpty) {
                 return const Center(child: AppText('No recent reports.'));
               }
               return ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: controller.recentReports.length > 5 ? 5 : controller.recentReports.length,
                 itemBuilder: (context, index) {
                   return _buildReportItem(controller.recentReports[index]);
                 },
               );
            }),
            const SizedBox(height: 80), // Prevent FAB overlap
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Obx(() {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.5,
        children: [
          _buildMetricCard(
             'Total Trips (M)',
             '${controller.totalTripsThisMonth}',
             Icons.route_outlined,
             AppColors.primaryColor,
          ),
          _buildMetricCard(
             'Revenue (M)',
             '\u20B9 ${(controller.totalRevenueThisMonth.value / 1000).toStringAsFixed(1)}k',
             Iconsax.card,
             AppColors.successColor,
          ),
          _buildMetricCard(
             'Active Vehicles',
             '${controller.activeVehiclesCount}',
             Iconsax.bus,
             AppColors.warningColor,
          ),
          _buildMetricCard(
             'Active Drivers',
             '${controller.activeDriversCount}',
             Icons.group_outlined,
             AppColors.infoColor,
          ),
        ],
      );
    });
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(child: AppText(title, style: AppTextStyle.caption, color: AppColors.textColorSecondary, maxLines: 1)),
            ],
          ),
          const SizedBox(height: 12),
           AppText(value, style: AppTextStyle.heading, fontSize: 24, color: AppColors.textColorPrimary),
        ],
      ),
    );
  }

  Widget _buildReportCategoryCards() {
    return Column(
      children: [
        Row(
          children: [
             Expanded(child: _buildCategoryCard('Trip Reports', Icons.commute_outlined, () => Get.toNamed(RouteHelper.getTripReportsRoute()))),
             const SizedBox(width: 16),
             Expanded(child: _buildCategoryCard('Financial Reports', Iconsax.empty_wallet, () => Get.toNamed(RouteHelper.getFinancialReportsRoute()))),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
         Row(
          children: [
             Expanded(child: _buildCategoryCard('Vehicle Reports', Icons.local_shipping_outlined, () => Get.toNamed(RouteHelper.getVehicleReportsRoute()))),
             const SizedBox(width: 16),
             Expanded(child: _buildCategoryCard('Staff Reports', Icons.badge_outlined, () => Get.toNamed(RouteHelper.getStaffReportsRoute()))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCategoryCard('Profit / Loss', Iconsax.chart_2, () => Get.toNamed(RouteHelper.getProfitLossReportRoute()))),
             const SizedBox(width: 16),
             const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 28),
          ),
          const SizedBox(height: 12),
          AppText(title, style: AppTextStyle.body, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildReportItem(ReportModel report) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: report.format == 'PDF' ? AppColors.errorColor.withOpacity(0.1) : AppColors.successColor.withOpacity(0.1),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Icon(
               report.format == 'PDF' ? Icons.picture_as_pdf_outlined : Icons.table_chart_outlined,
               color: report.format == 'PDF' ? AppColors.errorColor : AppColors.successColor,
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 AppText(report.reportName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                 const SizedBox(height: 4),
                 AppText('${report.type} • ${report.generatedDate.day}/${report.generatedDate.month}/${report.generatedDate.year}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
               ],
             ),
           ),
           IconButton(
             icon: const Icon(Iconsax.document_download, color: AppColors.primaryColor),
             onPressed: () {
                Get.snackbar('Downloading', '${report.reportName} is downloading...', snackPosition: SnackPosition.BOTTOM);
             },
           )
        ],
      ),
    );
  }

  void _showGenerateReportDialog(BuildContext context) {
    String selectedType = 'Operational';
    String selectedFormat = 'PDF';
    final TextEditingController nameController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Quick Generate Report', style: AppTextStyle.subheading, color: AppColors.primaryColor),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Report Name',
                hint: 'e.g. Weekly Summary',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              AppText('Report Type', style: AppTextStyle.label),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Financial', 'Operational', 'Compliance', 'Performance'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => selectedType = v!,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.slate200)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
               const SizedBox(height: 16),
                AppText('Format', style: AppTextStyle.label),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedFormat,
                items: ['PDF', 'CSV', 'Excel'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => selectedFormat = v!,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.slate200)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const AppText('Cancel', style: AppTextStyle.body, color: AppColors.textColorSecondary),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        Get.back();
                        controller.generateNewReport(nameController.text, selectedType, selectedFormat);
                      } else {
                         Get.snackbar('Error', 'Report name is required', backgroundColor: AppColors.errorColor, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const AppText('Generate', style: AppTextStyle.body, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
