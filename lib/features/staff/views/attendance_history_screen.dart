import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              onChanged: (v) {},
            ),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = controller.attendanceRecords[index];
                  return _HistoryCard(record: record);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AttendanceRecord record;
  const _HistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    '${record.date.day}/${record.date.month}/${record.date.year}',
                    style: AppTextStyle.caption,
                    color: AppColors.textColorSecondary,
                  ),
                  AppText(record.staffName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                ],
              ),
              const Spacer(),
              _buildLargeStatusBadge('Present'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeItem('In', record.checkIn != null ? '${record.checkIn!.hour}:${record.checkIn!.minute}' : '--:--'),
              _buildTimeItem('Out', record.checkOut != null ? '${record.checkOut!.hour}:${record.checkOut!.minute}' : '--:--'),
              _buildTimeItem('Total', '${record.totalHours}h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String label, String value) {
    return Column(
      children: [
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
        AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildLargeStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: AppText(
        status,
        style: AppTextStyle.caption,
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
