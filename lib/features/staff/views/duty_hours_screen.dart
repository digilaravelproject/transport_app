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

class DutyHoursScreen extends StatefulWidget {
  const DutyHoursScreen({Key? key}) : super(key: key);

  @override
  State<DutyHoursScreen> createState() => _DutyHoursScreenState();
}

class _DutyHoursScreenState extends State<DutyHoursScreen> {
  final controller = Get.find<StaffController>();
  late StaffModel staff;

  @override
  void initState() {
    super.initState();
    staff = Get.arguments ?? controller.staffList.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDutyHours(staff.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Duty Hours',
        subtitle: staff.name,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getAddDutyRecordRoute(), arguments: staff),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.dutyLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDutyHours(staff.id),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Duty Log'),
                if (controller.dutyLogs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: AppText('No duty logs found', color: AppColors.textColorSecondary),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.dutyLogs.length,
                    itemBuilder: (context, index) {
                      final log = controller.dutyLogs[index];
                      return _DutyCard(
                        date: log.date,
                        tripName: log.notes ?? 'Trip Record',
                        hours: log.totalHours,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    final summary = controller.dutyHoursSummary.value;
    return AppCard(
      child: Column(
        children: [
          const AppText('Working Hours Summary', style: AppTextStyle.subheading, fontSize: 16),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Today', '${summary?.today ?? 0.0}h', AppColors.primaryColor),
              _buildSummaryItem('Weekly', '${summary?.weekly ?? 0.0}h', Colors.orange),
              _buildSummaryItem('Monthly', '${summary?.monthly ?? 0.0}h', Colors.green),
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
  final String hours;

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
