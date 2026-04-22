import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../domain/models/staff_model.dart';

class AttendanceHistoryScreen extends GetView<StaffController> {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Attendance History',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search Staff Name',
              onChanged: (v) => controller.updateSearch(v),
            ),
          ),
          Expanded(
            child: Obx(() {
              final query = controller.searchQuery.value.toLowerCase();
              final records = controller.attendanceRecords
                  .where((r) => r.staffName.toLowerCase().contains(query))
                  .toList();

              if (records.isEmpty) {
                return const Center(child: AppText('No attendance history found', style: AppTextStyle.body));
              }

              // Group records by date
              final Map<String, List<AttendanceRecord>> grouped = {};
              for (var record in records) {
                final dateKey = _getDateLabel(record.date);
                if (!grouped.containsKey(dateKey)) grouped[dateKey] = [];
                grouped[dateKey]!.add(record);
              }

              final dateKeys = grouped.keys.toList();

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: dateKeys.length,
                itemBuilder: (context, dateIndex) {
                  final dateLabel = dateKeys[dateIndex];
                  final dailyRecords = grouped[dateLabel]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
                        child: AppText(dateLabel, style: AppTextStyle.subheading, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                      ),
                      ...dailyRecords.map((record) => _HistoryCard(record: record)).toList(),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) return 'Today, ${_formatDate(date)}';
    if (recordDate == yesterday) return 'Yesterday, ${_formatDate(date)}';
    return _formatDate(date, showDayName: true);
  }

  String _formatDate(DateTime date, {bool showDayName = false}) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return showDayName ? '$dayName, ${date.day} $monthName' : '${date.day} $monthName ${date.year}';
  }
}

class _HistoryCard extends StatelessWidget {
  final AttendanceRecord record;
  const _HistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final bool isAbsent = record.status == 'Absent';
    final bool isHalfDay = record.status == 'Half Day';
    final Color statusColor = isAbsent ? AppColors.errorColor : (isHalfDay ? AppColors.warningColor : AppColors.successColor);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.slate50,
                          child: Icon(Iconsax.user, size: 18, color: AppColors.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppText(record.staffName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                        ),
                        _buildStatusBadge(record.status ?? 'Present', statusColor),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeColumn('In', record.checkIn != null ? _formatTime(record.checkIn!) : '--:--', Iconsax.login_1),
                        _buildTimeColumn('Out', record.checkOut != null ? _formatTime(record.checkOut!) : '--:--', Iconsax.logout),
                        _buildTimeColumn('Total', '${record.totalHours}h', Iconsax.timer_1),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTimeColumn(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textColorSecondary),
            const SizedBox(width: 4),
            AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary, fontSize: 10),
          ],
        ),
        const SizedBox(height: 4),
        AppText(value, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: AppText(
        status,
        style: AppTextStyle.caption,
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
