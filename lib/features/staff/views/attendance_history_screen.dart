import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/attendance_history_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search_bar.dart';

class AttendanceHistoryScreen extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Attendance History',
        trailing: IconButton(
          icon: const Icon(Iconsax.filter),
          onPressed: () => controller.showFilterBottomSheet(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                AppSearchBar(
                  hint: 'Search Staff Name',
                  onChanged: (v) => controller.updateSearch(v),
                ),
                // Subtle loading indicator during search
                Obx(() => controller.isSearching.value
                    ? const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          color: AppColors.primaryColor,
                          backgroundColor: AppColors.slate100,
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              final records = controller.flattenedRecords;

              if (records.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.calendar_remove,
                        size: 64,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No results found for "${controller.searchQuery.value}"'
                            : 'No attendance history found',
                        style: AppTextStyle.body,
                        color: AppColors.textColorSecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => controller.refreshAttendanceHistory(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              // Group records by date
              final Map<String, List<AttendanceRecordWithStaff>> grouped = {};
              for (var record in records) {
                final dateKey = _getDateLabel(record.date);
                if (!grouped.containsKey(dateKey)) grouped[dateKey] = [];
                grouped[dateKey]!.add(record);
              }

              final dateKeys = grouped.keys.toList();

              return RefreshIndicator(
                onRefresh: () => controller.refreshAttendanceHistory(),
                color: AppColors.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: dateKeys.length,
                  itemBuilder: (context, dateIndex) {
                    final dateLabel = dateKeys[dateIndex];
                    final dailyRecords = grouped[dateLabel]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
                          child: AppText(
                            dateLabel,
                            style: AppTextStyle.subheading,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        ...dailyRecords.map((record) => _HistoryCard(record: record)).toList(),
                      ],
                    );
                  },
                ),
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
  final AttendanceRecordWithStaff record;
  const _HistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final bool isAbsent = record.status.toLowerCase() == 'absent';
    final bool isHalfDay = record.status.toLowerCase() == 'half' ||
                           record.status.toLowerCase() == 'half' ||
                           record.status.toLowerCase() == 'half';
    final Color statusColor = isAbsent 
        ? AppColors.errorColor 
        : (isHalfDay ? AppColors.warningColor : AppColors.successColor);

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
                          backgroundColor: AppColors.primaryLight,
                          child: AppText(
                            record.staffName.isNotEmpty 
                                ? record.staffName[0].toUpperCase() 
                                : '?',
                            style: AppTextStyle.body,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Expanded(
                              //   child:
                                AppText(
                                  record.staffName,
                                  style: AppTextStyle.body,
                                  fontWeight: FontWeight.bold,
                                ),
                              //),
                              AppText(record.staffType, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                            ],
                          ),
                        ),
                        _buildStatusBadge(record.displayStatus, statusColor),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeColumn(
                          'In',
                          record.inTime != null ? _formatTime(record.inTime!) : '--:--',
                          Iconsax.login_1,
                        ),
                        _buildTimeColumn(
                          'Out',
                          record.outTime != null ? _formatTime(record.outTime!) : '--:--',
                          Iconsax.logout,
                        ),
                        _buildTimeColumn(
                          'Total',
                          record.displayTotalHours,
                          Iconsax.timer_1,
                        ),
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

  String _formatTime(String time) {
    try {
      // Time format from API: "08:01:00" or "08:01"
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
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
