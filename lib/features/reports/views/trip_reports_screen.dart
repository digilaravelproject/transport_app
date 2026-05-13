import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/reports_controller.dart';
import '../domain/models/report_model.dart';

class TripReportsScreen extends GetView<ReportsController> {
  const TripReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch initial data if not already present
    if (controller.monthlyReport.value == null) {
      controller.fetchMonthlyReport();
    }

    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.monthlyReports.tr,
        rightWidget: IconButton(
          icon: const Icon(Iconsax.calendar_1, color: AppColors.primaryColor),
          onPressed: () => _showMonthPicker(context),
        ),
      ),
      body: Column(
        children: [
          _buildTypeSelection(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => AppText(
                        '${controller.selectedReportType.value.capitalizeFirst} ${AppTextConstants.reportLabel.tr} - ${_formatSelectedMonth(controller.selectedMonth.value)}',
                        style: AppTextStyle.subheading,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isMonthlyLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final report = controller.monthlyReport.value;
                    if (report == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Iconsax.document_filter, size: 64, color: AppColors.slate300),
                              const SizedBox(height: 16),
                              AppText(
                                AppTextConstants.noReportFoundCriteria.tr,
                                textAlign: TextAlign.center,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return _buildReportItem(report);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    final types = ['trip', 'vehicle', 'corporate', 'staff'];
    
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate200, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          return Obx(() {
            final isSelected = controller.selectedReportType.value == type;
            return GestureDetector(
              onTap: () => controller.updateReportType(type),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.slate50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                  ),
                ),
                child: Center(
                  child: AppText(
                    type.capitalizeFirst!,
                    color: isSelected ? Colors.white : AppColors.textColorSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          });
        },
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
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.document_text5,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(report.reportName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText(
                  '${AppTextConstants.generated.tr}: ${DateFormat('dd/MM/yyyy').format(report.generatedDate)}',
                  style: AppTextStyle.caption,
                  color: AppColors.textColorSecondary,
                ),
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
    }
  }

  void _downloadReport(ReportModel report) async {
    final urlString = AppConstants.getFileUrl(report.filePath);
    if (urlString.isEmpty) return;
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      Get.snackbar(AppTextConstants.downloading.tr, AppTextConstants.downloadStarted.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _formatSelectedMonth(String monthStr) {
    if (monthStr.isEmpty) return AppTextConstants.currentMonth.tr;
    try {
      final date = DateFormat('yyyy-MM').parse(monthStr);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return monthStr;
    }
  }

  void _showMonthPicker(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> months = List.generate(12, (index) {
      return DateTime(now.year, now.month - index, 1);
    });

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.slate200, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            AppText(AppTextConstants.selectMonth.tr, style: AppTextStyle.subheading, fontWeight: FontWeight.bold),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = months[index];
                  final monthKey = DateFormat('yyyy-MM').format(month);
                  final isSelected = controller.selectedMonth.value == monthKey;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Icon(Iconsax.calendar_1, color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary),
                    title: AppText(DateFormat('MMMM yyyy').format(month), color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primaryColor) : null,
                    onTap: () {
                      controller.updateSelectedMonth(monthKey);
                      Get.back();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
