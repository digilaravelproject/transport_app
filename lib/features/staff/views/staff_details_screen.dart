import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_constants.dart';
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

class StaffDetailsScreen extends StatefulWidget {
  const StaffDetailsScreen({Key? key}) : super(key: key);

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  final controller = Get.find<StaffController>();
  late int staffId;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    if (args is String) {
      staffId = int.tryParse(args) ?? (controller.staffList.isNotEmpty ? controller.staffList.first.id : 0);
    } else if (args is int) {
      staffId = args;
    } else {
      staffId = (args as StaffModel?)?.id ?? (controller.staffList.isNotEmpty ? controller.staffList.first.id : 0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshStaffDetails(staffId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final StaffModel? staff = controller.staffList.firstWhereOrNull((s) => s.id == staffId);

      if (staff == null) {
        return AppScaffold(
          appBar: AppHeader(title: AppTextConstants.staffDetails.tr),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return AppScaffold(
        appBar: AppHeader(
          title: AppTextConstants.staffDetails.tr,
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
            await controller.refreshStaffDetails(staffId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(staff),
                const SizedBox(height: 24),
                _buildSectionTitle(AppTextConstants.personalInformation.tr),
                _buildPersonalInfo(staff),
                const SizedBox(height: 24),
                _buildSectionTitle(AppTextConstants.workInformation.tr),
                _buildWorkInfo(staff),
                const SizedBox(height: 24),
                _buildSectionTitle(AppTextConstants.identificationDocuments.tr),
                _buildDocumentsInfo(staff),
                const SizedBox(height: 12),
                _buildSectionTitle(AppTextConstants.actions.tr),
                _buildActionsGrid(staff),
                const SizedBox(height: 32),
                AppButton.outline(
                  text: AppTextConstants.editStaff.tr,
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
                backgroundImage: (staff.photoUrl ?? '').isNotEmpty ? NetworkImage(staff.photoUrl!) : null,
                child: (staff.photoUrl ?? '').isEmpty ? const Icon(Iconsax.user, size: 40, color: AppColors.primaryColor) : null,
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
                    AppText(staff.roleName ?? 'N/A', style: AppTextStyle.body, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(Iconsax.call, AppTextConstants.phone.tr, staff.phone),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.sms, AppTextConstants.email.tr, staff.email),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.location, AppTextConstants.address.tr, staff.address),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(StaffModel staff) {
    return AppCard(
      child: Column(
        children: [
          _buildInfoRow(Iconsax.calendar_1, AppTextConstants.dateOfBirth.tr, staff.dob != null ? '${staff.dob!.day}/${staff.dob!.month}/${staff.dob!.year}' : 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.calendar_1, AppTextConstants.joiningDate.tr, staff.joiningDate != null ? '${staff.joiningDate!.day}/${staff.joiningDate!.month}/${staff.joiningDate!.year}' : 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.user, AppTextConstants.emergencyName.tr, staff.emergencyContactName ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.call, AppTextConstants.emergencyPhone.tr, staff.emergencyContact ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildWorkInfo(StaffModel staff) {
    return AppCard(
      child: Column(
        children: [
          _buildInfoRow(Iconsax.card, AppTextConstants.monthlySalary.tr, '₹ ${staff.salary}'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.money_send, AppTextConstants.daPerDay.tr, '₹ ${staff.daPerDay ?? 0}'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.house, AppTextConstants.hra.tr, '₹ ${staff.hra ?? 0}'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.clock, AppTextConstants.workingShift.tr, staff.shiftName ?? 'N/A'),
          if (staff.assignedVehicleNumber != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Iconsax.bus, AppTextConstants.assignedVehicle.tr, staff.assignedVehicleNumber!),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsInfo(StaffModel staff) {
    return AppCard(
      child: Column(
        children: [
          _buildInfoRow(Icons.badge_outlined, AppTextConstants.aadharNumber.tr, staff.aadharNumber ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.card_pos, AppTextConstants.panNumber.tr, staff.panNumber ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.drive_eta, AppTextConstants.licenseNumber.tr, staff.licenseNumber ?? 'N/A'),
          if (staff.licenseExpiry != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Iconsax.calendar_tick, AppTextConstants.licenseExpiry.tr, '${staff.licenseExpiry!.day}/${staff.licenseExpiry!.month}/${staff.licenseExpiry!.year}'),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.verify, AppTextConstants.badgeNumber.tr, staff.badgeNumber ?? 'N/A'),
          if (staff.badgeExpiry != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Iconsax.calendar_tick, AppTextConstants.badgeExpiry.tr, '${staff.badgeExpiry!.day}/${staff.badgeExpiry!.month}/${staff.badgeExpiry!.year}'),
          ],
          const Divider(height: 32),
          _buildSectionTitle(AppTextConstants.bankDetails.tr),
          _buildInfoRow(Iconsax.bank, AppTextConstants.bankName.tr, staff.bankName ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.card, AppTextConstants.accountNo.tr, staff.bankAccount ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow(Iconsax.code, AppTextConstants.ifscCode.tr, staff.bankIfsc ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildActionsGrid(StaffModel staff) {
    final List<Map<String, dynamic>> actions = [
      {'label': AppTextConstants.dutyHours.tr, 'icon': Icons.more_time_rounded, 'route': RouteHelper.getDutyHoursRoute()},
      {'label': AppTextConstants.salary.tr, 'icon': Icons.wallet_rounded, 'route': RouteHelper.getSalaryManagementRoute()},
      {'label': AppTextConstants.advance.tr, 'icon': Icons.request_quote_rounded, 'route': RouteHelper.getAdvanceHistoryRoute()},
      {'label': AppTextConstants.documents.tr, 'icon': Icons.folder_shared_rounded, 'route': RouteHelper.getStaffDocumentsRoute()},
      {'label': AppTextConstants.performance.tr, 'icon': Icons.speed_rounded, 'route': RouteHelper.getStaffPerformanceRoute()},
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

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isMultiLine ? 2 : 0),
          child: Icon(icon, size: 16, color: AppColors.textColorHint),
        ),
        const SizedBox(width: 10),
        AppText('$label: ', style: AppTextStyle.body, fontWeight: FontWeight.w500),
        Expanded(
          child: AppText(
            value, 
            style: AppTextStyle.body, 
            color: AppColors.textColorSecondary,
            maxLines: isMultiLine ? 2 : 1,
            overflow: isMultiLine ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, StaffModel staff) {
    Get.dialog(
      AlertDialog(
        title: AppText(AppTextConstants.deleteStaff.tr, style: AppTextStyle.subheading, fontSize: 18),
        content: AppText(AppTextConstants.deleteConfirmation.tr, style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(AppTextConstants.cancel.tr, color: AppColors.textColorSecondary),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteStaff(staff.id);
            },
            child: AppText(AppTextConstants.delete.tr, color: AppColors.errorColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
