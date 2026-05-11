import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/reports_controller.dart';
import '../domain/models/report_model.dart';

class AllReportsScreen extends GetView<ReportsController> {
  const AllReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.allReports.isEmpty) {
        controller.fetchAllReports(isRefresh: true);
      }
    });

    return AppScaffold(
      appBar: const AppHeader(title: 'All Reports'),
      body: Obx(() {
        if (controller.isMoreLoading.value && controller.allReports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allReports.isEmpty && !controller.isMoreLoading.value) {
          return const Center(child: AppText('No reports found.'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAllReports(isRefresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.allReports.length + (controller.hasMoreData.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.allReports.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.fetchAllReports();
                });
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final report = controller.allReports[index];
              return _buildReportItem(report);
            },
          ),
        );
      }),
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
      Get.snackbar('Error', 'Could not open report');
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
      Get.snackbar('Error', 'Could not download report');
    }
  }
}
