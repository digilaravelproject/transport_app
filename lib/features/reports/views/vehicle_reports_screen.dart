import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/reports_controller.dart';
import '../domain/models/report_model.dart';

class VehicleReportsScreen extends GetView<ReportsController> {
  const VehicleReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reports = controller.recentReports.where((r) => r.type == 'Operational').toList();

    return AppScaffold(
      appBar: AppHeader(
        title: 'Vehicle Reports',
        rightWidget: IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryColor),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
             if (reports.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: AppText('No vehicle reports found.')))
             else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportItem(reports[index]);
                  },
                ),
          ],
        ),
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
               color: AppColors.warningColor.withOpacity(0.1),
               borderRadius: BorderRadius.circular(12),
             ),
             child: const Icon(
               Iconsax.bus,
               color: AppColors.warningColor,
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 AppText(report.reportName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                 const SizedBox(height: 4),
                 AppText('Generated: ${report.generatedDate.day}/${report.generatedDate.month}/${report.generatedDate.year}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
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
}
