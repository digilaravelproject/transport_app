import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../routes/route_helper.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class StaffDetailsScreen extends GetView<StaffController> {
  const StaffDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int staffId = (Get.arguments as StaffModel?)?.id ?? (controller.staffList.isNotEmpty ? controller.staffList.first.id : 0);

    return Obx(() {
      final StaffModel? staff = controller.staffList.firstWhereOrNull((s) => s.id == staffId);

      if (staff == null) {
        return const AppScaffold(
          appBar: AppHeader(title: 'Staff Details'),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return AppScaffold(
        appBar: AppHeader(
          title: 'Staff Details',
          subtitle: staff.name,
          trailing: Row(
            children: [
              IconButton(
                icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
                onPressed: () => Get.toNamed(RouteHelper.getEditStaffRoute(), arguments: staff),
              ),
              IconButton(
                icon: const Icon(Iconsax.profile_delete, color: AppColors.errorColor),
                onPressed: () => _showDeleteConfirmation(context, staff),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchStaff();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(staff),
                const SizedBox(height: 24),
                _buildSectionTitle('Personal Information'),
                _buildPersonalInfo(staff),
                const SizedBox(height: 24),
                _buildSectionTitle('Work Information'),
                _buildWorkInfo(staff),
                const SizedBox(height: 12),
                _buildSectionTitle('Actions'),
                _buildActionsGrid(staff),
                const SizedBox(height: 32),
                AppButton.outline(
                  text: 'Edit Staff',
                  onPressed: () => Get.toNamed(RouteHelper.getEditStaffRoute(), arguments: staff),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProfileHeader(StaffModel staff) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Iconsax.user, size: 40, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(staff.name, style: AppTextStyle.heading, fontSize: 20),
                        AppStatusChip(status: staff.status.name.capitalizeFirst!),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(staff.roleName!, style: AppTextStyle.body, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(Iconsax.call, 'Phone', staff.phone),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.sms, 'Email', staff.email),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.location, 'Address', staff.address),
          if (staff.licenseNumber != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.badge_outlined, 'DL Number', staff.licenseNumber!),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(StaffModel staff) {
    return AppCard(
      child: Column(
        children: [
          _buildInfoRow(Iconsax.location, 'Address', staff.address),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.calendar_1, 'Joining Date', staff.joiningDate != null ? '${staff.joiningDate!.day}/${staff.joiningDate!.month}/${staff.joiningDate!.year}' : 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.badge_outlined, 'Aadhar Number', staff.aadharNumber ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildWorkInfo(StaffModel staff) {
    return AppCard(
      child: Column(
        children: [
          _buildInfoRow(Iconsax.card, 'Monthly Salary', '₹ ${staff.salary}'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.clock, 'Working Shift', staff.shiftName ?? 'N/A'),
          if (staff.assignedVehicleNumber != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Iconsax.bus, 'Assigned Vehicle', staff.assignedVehicleNumber!),
          ],
        ],
      ),
    );
  }


  Widget _buildActionsGrid(StaffModel staff) {
    final List<Map<String, dynamic>> actions = [
      {'label': 'Duty Hours', 'icon': Icons.more_time_rounded, 'route': RouteHelper.getDutyHoursRoute()},
      {'label': 'Salary', 'icon': Icons.wallet_rounded, 'route': RouteHelper.getSalaryManagementRoute()},
      {'label': 'Advance', 'icon': Icons.request_quote_rounded, 'route': RouteHelper.getAdvancePaymentEntryRoute()},
      {'label': 'Documents', 'icon': Icons.folder_shared_rounded, 'route': RouteHelper.getStaffDocumentsRoute()},
      {'label': 'Performance', 'icon': Icons.speed_rounded, 'route': RouteHelper.getStaffPerformanceRoute()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return AppCard(
          padding: const EdgeInsets.all(8),
          onTap: () => Get.toNamed(actions[index]['route'], arguments: staff),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(actions[index]['icon'], color: AppColors.primaryColor, size: 24),
              const SizedBox(height: 8),
              AppText(actions[index]['label'], style: AppTextStyle.body, fontSize: 11, fontWeight: FontWeight.w600, align: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: AppText(title, style: AppTextStyle.subheading, fontSize: 14, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textColorHint),
        const SizedBox(width: 10),
        AppText('$label: ', style: AppTextStyle.body, fontWeight: FontWeight.w500),
        Expanded(child: AppText(value, style: AppTextStyle.body, color: AppColors.textColorSecondary)),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, StaffModel staff) {
    Get.dialog(
      AlertDialog(
        title: const AppText('Delete Staff', style: AppTextStyle.subheading, fontSize: 18),
        content: AppText('Are you sure you want to delete ${staff.name}?', style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteStaff(staff.id);
            },
            child: const AppText('Delete', color: AppColors.errorColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
