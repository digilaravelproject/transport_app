import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/finance_controller.dart';

class FinanceScreen extends GetView<FinanceController> {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final data = controller.dashboardData.value;
        final isLoading = controller.isDashboardLoading.value;

        return Column(
          children: [
            // Fixed Top Bar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (Navigator.of(context).canPop())
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.arrow_left_2,
                            color: AppColors.textColorPrimary, size: 20),
                      ),
                    )
                  else
                    const SizedBox(width: 36),
                  
                  GestureDetector(
                    onTap: () => _showMonthPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.calendar_2, color: AppColors.primaryColor, size: 14),
                          const SizedBox(width: 6),
                          AppText(
                            _formatSelectedMonth(controller.selectedMonth.value),
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(width: 4),
                          const Icon(Iconsax.arrow_down_1, color: AppColors.primaryColor, size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (data == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.danger, size: 48, color: AppColors.slate400),
                      const SizedBox(height: 16),
                      const AppText('Failed to load financial data'),
                      TextButton(
                        onPressed: () => controller.fetchFinanceDashboard(controller.selectedMonth.value),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchFinanceDashboard(controller.selectedMonth.value),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Title
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'Finance Dashboard',
                                style: AppTextStyle.heading,
                                fontSize: 28,
                                color: AppColors.textColorPrimary,
                              ),
                              SizedBox(height: 4),
                              AppText(
                                'Track revenue, expenses & profitability',
                                style: AppTextStyle.body,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Top Stat Cards Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Revenue',
                                  value: '₹${_formatAmount(data.totalRevenue)}',
                                  color: const Color(0xFF10B981),
                                  icon: Iconsax.card,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Expenses',
                                  value: '₹${_formatAmount(data.totalExpenses)}',
                                  color: const Color(0xFFEF4444),
                                  icon: Iconsax.receipt_2_1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Profit',
                                  value: '₹${_formatAmount(data.totalProfit)}',
                                  color: AppColors.successColor,
                                  icon: Iconsax.trend_up,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Pending Card (full width)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Iconsax.timer_15,
                                      color: Color(0xFFF59E0B), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      '₹ ${_formatAmount(data.pendingAmount)}',
                                      style: AppTextStyle.heading,
                                      fontSize: 22,
                                      color: AppColors.textColorPrimary,
                                    ),
                                    const SizedBox(height: 2),
                                    const AppText(
                                      'Pending Payments',
                                      style: AppTextStyle.label,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColorSecondary,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const AppText(
                                    'Collect',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Financial Overview Chart
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: AppText(
                            'Financial Overview',
                            style: AppTextStyle.subheading,
                            fontSize: 16,
                            color: AppColors.textColorPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AppCard(
                            padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 220,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: _getMaxValue(data) > 0 ? _getMaxValue(data) : 100,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipColor: (_) => AppColors.slate800.withOpacity(0.9),
                                          tooltipRoundedRadius: 8,
                                          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            String category = '';
                                            switch (group.x.toInt()) {
                                              case 0: category = 'Revenue'; break;
                                              case 1: category = 'Expenses'; break;
                                              case 2: category = 'Profit'; break;
                                              case 3: category = 'Pending'; break;
                                            }
                                            return BarTooltipItem(
                                              '$category\n',
                                              const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.normal),
                                              children: [
                                                TextSpan(
                                                  text: '₹${rod.toY.toStringAsFixed(0)}',
                                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              const titles = ['Rev', 'Exp', 'Profit', 'Pend'];
                                              if (value.toInt() >= 0 && value.toInt() < titles.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 10.0),
                                                  child: AppText(titles[value.toInt()], 
                                                      fontSize: 11, 
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.textColorSecondary),
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              if (value == 0) return const SizedBox();
                                              return AppText(
                                                _formatAmount(value),
                                                fontSize: 10,
                                                color: AppColors.textColorHint,
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: _getMaxValue(data) > 0 ? _getMaxValue(data) / 4 : 25,
                                        getDrawingHorizontalLine: (value) => FlLine(
                                          color: AppColors.slate200.withOpacity(0.6),
                                          strokeWidth: 1,
                                          dashArray: [5, 5],
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        _makeGroupData(0, data.totalRevenue, AppColors.primaryColor),
                                        _makeGroupData(1, data.totalExpenses, AppColors.errorColor),
                                        _makeGroupData(2, data.totalProfit, AppColors.successColor),
                                        _makeGroupData(3, data.pendingAmount, AppColors.warningColor),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Legend
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem('Revenue', AppColors.primaryColor),
                                    const SizedBox(width: 12),
                                    _buildLegendItem('Expense', AppColors.errorColor),
                                    const SizedBox(width: 12),
                                    _buildLegendItem('Profit', AppColors.successColor),
                                    const SizedBox(width: 12),
                                    _buildLegendItem('Pending Payment', AppColors.warningColor),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Summary List or Trip list if needed
                        /*if (data.completedTrips.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: AppText(
                              'Recent Trips',
                              style: AppTextStyle.subheading,
                              fontSize: 16,
                              color: AppColors.textColorPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...data.completedTrips.map((trip) => _TripItem(trip: trip)).toList(),
                        ],*/
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  double _getMaxValue(dynamic data) {
    double maxVal = [data.totalRevenue, data.totalExpenses, data.totalProfit, data.pendingAmount]
        .reduce((curr, next) => curr > next ? curr : next);
    return maxVal > 0 ? maxVal * 1.2 : 0;
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _getMaxValue(controller.dashboardData.value!),
            color: color.withOpacity(0.05),
          ),
        ),
      ],
      showingTooltipIndicators: [],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        AppText(label, fontSize: 10, color: AppColors.textColorSecondary),
      ],
    );
  }

  String _formatSelectedMonth(String monthStr) {
    if (monthStr.isEmpty) return 'Select Month';
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const AppText('Select Month', style: AppTextStyle.subheading, fontWeight: FontWeight.bold),
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
                    leading: Icon(
                      Iconsax.calendar_1,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
                    ),
                    title: AppText(
                      DateFormat('MMMM yyyy').format(month),
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    trailing: isSelected 
                      ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                      : null,
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          AppText(
            value,
            style: AppTextStyle.heading,
            fontSize: 18,
            color: AppColors.textColorPrimary,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          AppText(
            title,
            style: AppTextStyle.label,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}

class _TripItem extends StatelessWidget {
  final dynamic trip;
  const _TripItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.routing, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(trip.tripNumber, fontWeight: FontWeight.bold, fontSize: 14),
                const SizedBox(height: 2),
                AppText(trip.route, fontSize: 12, color: AppColors.textColorSecondary, maxLines: 1),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText('₹${trip.revenue}', fontWeight: FontWeight.bold, color: AppColors.successColor, fontSize: 14),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (trip.paymentStatus == 'paid' ? AppColors.successColor : AppColors.warningColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AppText(
                  trip.paymentStatus.toUpperCase(), 
                  fontSize: 8, 
                  fontWeight: FontWeight.bold,
                  color: trip.paymentStatus == 'paid' ? AppColors.successColor : AppColors.warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
