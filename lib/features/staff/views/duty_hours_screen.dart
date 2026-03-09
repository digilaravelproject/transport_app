import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';
import '../../../routes/route_helper.dart';

class DutyHoursScreen extends GetView<StaffController> {
  const DutyHoursScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments ?? controller.staffList.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Duty Hours',
        subtitle: staff.name,
      ),
      floatingActionButton: FloatingActionButton(heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getAddDutyRecordRoute(), arguments: staff),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryCard(staff),
            const SizedBox(height: 24),
            _buildSectionTitle('Duty Log'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _DutyCard(
                  date: DateTime.now().subtract(Duration(days: index)),
                  tripName: 'Trip #${1000 + index} - Delhi to Jaipur',
                  hours: 8.5 - index,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(StaffModel staff) {
    return AppCard(
      child: Column(
        children: [
          const AppText('Working Hours Summary', style: AppTextStyle.subheading, fontSize: 16),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Today', '8.5h', AppColors.primaryColor),
              _buildSummaryItem('Weekly', '45h', Colors.orange),
              _buildSummaryItem('Monthly', '${staff.dutyHours}h', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        AppText(value, style: AppTextStyle.heading, fontSize: 24, color: color),
        const SizedBox(height: 4),
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: AppText(title, style: AppTextStyle.subheading, fontSize: 14, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DutyCard extends StatelessWidget {
  final DateTime date;
  final String tripName;
  final double hours;

  const _DutyCard({required this.date, required this.tripName, required this.hours});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Iconsax.clock, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(tripName, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText('${date.day}/${date.month}/${date.year}', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          AppText('${hours}h', style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.successColor),
        ],
      ),
    );
  }
}
