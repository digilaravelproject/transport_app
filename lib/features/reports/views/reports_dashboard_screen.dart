import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
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
import '../../../core/utils/app_validators.dart';

class ReportsDashboardScreen extends GetView<ReportsController> {
  const ReportsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.reportsAnalytics.tr,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showGenerateReportBottomSheet(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: AppText(AppTextConstants.generateReport.tr, style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
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
                AppText(AppTextConstants.generateSpecificReports.tr, style: AppTextStyle.subheading),
              ],
            ),
            const SizedBox(height: 12),
            _buildReportCategoryCards(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(AppTextConstants.recentReports.tr, style: AppTextStyle.subheading),
                TextButton(
                  onPressed: () => Get.toNamed(RouteHelper.getAllReportsRoute()),
                  child: AppText(AppTextConstants.viewAll.tr, style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.recentReports.isEmpty) {
                return Center(child: AppText(AppTextConstants.noRecentReports.tr));
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
            AppTextConstants.totalTripsMonth.tr,
            '${controller.totalTripsThisMonth}',
            Icons.route_outlined,
            AppColors.primaryColor,
          ),
          _buildMetricCard(
            AppTextConstants.revenueMonth.tr,
            '\u20B9 ${(controller.totalRevenueThisMonth.value / 1000).toStringAsFixed(1)}k',
            Iconsax.card,
            AppColors.successColor,
          ),
          _buildMetricCard(
            AppTextConstants.activeVehicles.tr,
            '${controller.activeVehiclesCount}',
            Iconsax.bus,
            AppColors.warningColor,
          ),
          _buildMetricCard(
            AppTextConstants.activeDrivers.tr,
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
            Expanded(child: _buildCategoryCard(AppTextConstants.tripReports.tr, Icons.commute_outlined, () => Get.toNamed(RouteHelper.getTripReportsRoute()))),
            const SizedBox(width: 16),
            Expanded(child: _buildCategoryCard(AppTextConstants.financialReports.tr, Iconsax.empty_wallet, () => Get.toNamed(RouteHelper.getFinancialReportsRoute()))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCategoryCard(AppTextConstants.vehicleReports.tr, Icons.local_shipping_outlined, () => Get.toNamed(RouteHelper.getVehicleReportsRoute()))),
            const SizedBox(width: 16),
            Expanded(child: _buildCategoryCard(AppTextConstants.staffReports.tr, Icons.badge_outlined, () => Get.toNamed(RouteHelper.getStaffReportsRoute()))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCategoryCard(AppTextConstants.profitLoss.tr, Iconsax.chart_2, () => Get.toNamed(RouteHelper.getProfitLossReportRoute()))),
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
      onTap: () => _viewReport(report),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: report.format.toUpperCase() == 'PDF' ? AppColors.errorColor.withOpacity(0.1) : AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              report.format.toUpperCase() == 'PDF' ? Icons.picture_as_pdf_outlined : Icons.table_chart_outlined,
              color: report.format.toUpperCase() == 'PDF' ? AppColors.errorColor : AppColors.successColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(report.reportName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText('${report.type} • ${report.generatedDate.day}/${report.generatedDate.month}/${report.generatedDate.year}',
                    style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.document_download, color: AppColors.primaryColor),
            onPressed: () => _downloadReport(report),
          )
        ],
      ),
    );
  }

  void _viewReport(ReportModel report) async {
    final urlString = AppConstants.getFileUrl(report.filePath);
    if (urlString.isEmpty) return;
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(AppTextConstants.error.tr, 'Could not open report');
    }
  }

  void _downloadReport(ReportModel report) async {
    final urlString = AppConstants.getFileUrl(report.filePath);
    if (urlString.isEmpty) return;
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      Get.snackbar('Downloading', 'Report download started...', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar(AppTextConstants.error.tr, 'Could not download report');
    }
  }

  void _showGenerateReportBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final fromDateController = TextEditingController();
    final toDateController = TextEditingController();
    
    DateTime? fromDate;
    DateTime? toDate;
    
    RxString selectedType = 'Financial'.obs;
    RxString selectedFormat = 'pdf'.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(AppTextConstants.generateReport.tr, style: AppTextStyle.subheading, fontSize: 20),
                    IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 24),
                AppInputField(
                  label: AppTextConstants.reportName.tr,
                  hint: AppTextConstants.enterReportName.tr,
                  controller: nameController,
                  validator: (v) => AppValidators.validateEmpty(v, fieldName: AppTextConstants.reportName.tr),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        AppTextConstants.reportType.tr,
                        selectedType,
                        ['Financial', 'Operational', 'Compliance', 'Performance'],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        AppTextConstants.format.tr,
                        selectedFormat,
                        ['pdf', 'csv', 'excel'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppInputField(
                        label: AppTextConstants.fromDate.tr,
                        hint: 'YYYY-MM-DD',
                        controller: fromDateController,
                        readOnly: true,
                        icon: Iconsax.calendar_1,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            fromDate = date;
                            fromDateController.text = DateFormat('yyyy-MM-dd').format(date);
                          }
                        },
                        validator: (v) => AppValidators.validateEmpty(v, fieldName: AppTextConstants.fromDate.tr),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppInputField(
                        label: AppTextConstants.toDate.tr,
                        hint: 'YYYY-MM-DD',
                        controller: toDateController,
                        readOnly: true,
                        icon: Iconsax.calendar_1,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            toDate = date;
                            toDateController.text = DateFormat('yyyy-MM-dd').format(date);
                          }
                        },
                        validator: (v) => AppValidators.validateEmpty(v, fieldName: AppTextConstants.toDate.tr),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Obx(() => AppButton(
                  text: AppTextConstants.generateReport.tr,
                  isLoading: controller.isLoading.value,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final success = await controller.generateReport({
                        "name": nameController.text,
                        "type": selectedType.value,
                        "format": selectedFormat.value,
                        "from": fromDateController.text,
                        "to": toDateController.text,
                      });
                      if (success) {
                        Get.back();
                      }
                    }
                  },
                )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDropdown(String label, RxString value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: AppText(item, style: AppTextStyle.body, fontSize: 13),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) value.value = newValue;
              },
            ),
          )),
        ),
      ],
    );
  }
}
