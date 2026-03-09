import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class StaffPerformanceScreen extends GetView<StaffController> {
  const StaffPerformanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments ?? controller.staffList.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Performance Report',
        subtitle: staff.name,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallRating(staff),
            const SizedBox(height: 24),
            _buildSectionTitle('Efficiency Metrics'),
            _buildMetricsGrid(staff),
            const SizedBox(height: 24),
            _buildSectionTitle('Monthly Trip History'),
            _buildTripChart(staff),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Feedback'),
            _buildFeedbackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRating(StaffModel staff) {
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
                    const AppText('4.8', style: AppTextStyle.heading, fontSize: 24),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                        color: Colors.amber,
                        size: 18,
                      )),
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

  Widget _buildMetricsGrid(StaffModel staff) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard('On-Time', '98%', Icons.timer_rounded, Colors.green),
        _buildMetricCard('Fuel Efficiency', '12 km/l', Icons.local_gas_station_rounded, Colors.blue),
        _buildMetricCard('Safety Violations', '0', Icons.gpp_good_rounded, Colors.orange),
        _buildMetricCard('Customer Satisfaction', '95%', Icons.sentiment_very_satisfied_rounded, Colors.purple),
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

  Widget _buildTripChart(StaffModel staff) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Trips per Month', style: AppTextStyle.body, fontWeight: FontWeight.w600),
              const AppText('Last 6 Months', style: AppTextStyle.caption),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(20, 'Jan'),
                _buildBar(35, 'Feb'),
                _buildBar(50, 'Mar'),
                _buildBar(45, 'Apr'),
                _buildBar(60, 'May'),
                _buildBar(55, 'Jun'),
              ],
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

  Widget _buildFeedbackList() {
    return Column(
      children: [
        _buildFeedbackItem('Excellent service, reached on time.', 'Trip #1024', DateTime.now().subtract(const Duration(days: 2))),
        _buildFeedbackItem('Driver was polite and the bus was clean.', 'Trip #1015', DateTime.now().subtract(const Duration(days: 5))),
      ],
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
