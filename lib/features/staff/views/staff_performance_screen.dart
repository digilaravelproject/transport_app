import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';
import '../../../core/constants/app_constants.dart';

class StaffPerformanceScreen extends GetView<StaffController> {
  const StaffPerformanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments ?? controller.staffList.first;

    // Fetch performance data on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchStaffPerformance(staff.id);
    });

    return AppScaffold(
      appBar: AppHeader(
        title: 'Performance Report',
        subtitle: staff.name,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.performanceReport.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final report = controller.performanceReport.value;
        if (report == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 64, color: AppColors.textColorHint.withOpacity(0.5)),
                const SizedBox(height: 16),
                const AppText('No performance data found', style: AppTextStyle.body, color: AppColors.textColorHint),
                const SizedBox(height: 16),
                AppButton.outline(
                  text: 'Retry',
                  onPressed: () => controller.fetchStaffPerformance(staff.id),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchStaffPerformance(staff.id),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallRating(report),
                const SizedBox(height: 24),
                _buildSectionTitle('Efficiency Metrics'),
                _buildMetricsGrid(report),
                const SizedBox(height: 24),
                _buildSectionTitle('Monthly Trip History'),
                _buildTripChart(report),
                const SizedBox(height: 24),
                _buildSectionTitle('Recent Feedback'),
                _buildFeedbackList(report),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverallRating(PerformanceReportModel report) {
    final score = report.overallScore ?? 0.0;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: AppColors.primaryColor, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Overall Driver Score', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AppText(score.toStringAsFixed(1), style: AppTextStyle.heading, fontSize: 24),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (index) {
                        if (index < score.floor()) {
                          return const Icon(Icons.star_rounded, color: Colors.amber, size: 18);
                        } else if (index < score) {
                          return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 18);
                        } else {
                          return const Icon(Icons.star_outline_rounded, color: Colors.amber, size: 18);
                        }
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(PerformanceReportModel report) {
    final metrics = report.efficiencyMetrics;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          'On-Time', 
          metrics['on_time'] != null ? '${metrics['on_time']}%' : 'N/A', 
          Icons.timer_rounded, 
          Colors.green
        ),
        _buildMetricCard(
          'Fuel Efficiency', 
          metrics['fuel_efficiency'] != null ? '${metrics['fuel_efficiency']} km/l' : 'N/A', 
          Icons.local_gas_station_rounded, 
          Colors.blue
        ),
        _buildMetricCard(
          'Safety Violations', 
          (metrics['safety_violations'] ?? 0).toString(), 
          Icons.gpp_good_rounded, 
          Colors.orange
        ),
        _buildMetricCard(
          'Customer Satisfaction', 
          metrics['customer_satisfaction'] != null ? '${metrics['customer_satisfaction']}%' : 'N/A', 
          Icons.sentiment_very_satisfied_rounded, 
          Colors.purple
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          AppText(value, style: AppTextStyle.subheading, fontSize: 16, fontWeight: FontWeight.bold),
          AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary, fontSize: 11),
        ],
      ),
    );
  }

  Widget _buildTripChart(PerformanceReportModel report) {
    final history = report.monthlyTripHistory;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Trips per Month', style: AppTextStyle.body, fontWeight: FontWeight.w600),
              AppText(history.isNotEmpty ? 'Last ${history.length} Months' : 'Last 6 Months', style: AppTextStyle.caption),
            ],
          ),
          const SizedBox(height: 24),
          if (history.isEmpty)
             const SizedBox(height: 120, child: Center(child: AppText('No trip history', style: AppTextStyle.caption)))
          else
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: history.map((e) {
                   // Calculate relative height based on max trips (capped at 100 for safety)
                   int maxTrips = 0;
                   for(var h in history) if(h.trips > maxTrips) maxTrips = h.trips;
                   if(maxTrips == 0) maxTrips = 1;
                   
                   double height = (e.trips / maxTrips) * 100;
                   if (height < 5) height = 5; // Minimum height for visibility
                   
                   return _buildBar(height, e.month);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        AppText(label, style: AppTextStyle.caption, fontSize: 10),
      ],
    );
  }

  Widget _buildFeedbackList(PerformanceReportModel report) {
    if (report.recentFeedback.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: AppCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textColorHint.withOpacity(0.3)),
              const SizedBox(height: 12),
              const AppText('No recent feedback', style: AppTextStyle.body, color: AppColors.textColorHint),
            ],
          ),
        ),
      );
    }
    return Column(
      children: report.recentFeedback.map((f) {
        // Assuming feedback structure from API
        return _buildFeedbackItem(
          f['comment'] ?? 'No comment provided', 
          'Trip #${f['trip_id'] ?? 'N/A'}', 
          f['date'] != null ? DateTime.tryParse(f['date'].toString()) ?? DateTime.now() : DateTime.now()
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackItem(String text, String tripId, DateTime date) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(tripId, style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              AppText('${date.day}/${date.month}', style: AppTextStyle.caption),
            ],
          ),
          const SizedBox(height: 8),
          AppText(text, style: AppTextStyle.body, fontSize: 13),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: AppText(title, style: AppTextStyle.subheading, fontSize: 14, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
    );
  }
}
