import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:credit_debit/core/theme/app_colors.dart';
import 'package:credit_debit/core/widgets/app_scaffold.dart';
import 'package:credit_debit/core/widgets/app_header.dart';
import 'package:credit_debit/core/widgets/app_card.dart';
import 'package:credit_debit/core/widgets/app_text.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_text_constants.dart';
import '../../settings/views/profile_screen.dart';
import '../../membership/controllers/membership_controller.dart';
import '../../membership/views/membership_screen.dart';
import '../../membership/views/active_subscription_screen.dart';
import '../../../routes/route_helper.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Standardized module list using AppColors and theme-aligned colors
    final modules = [
      _ModuleItem(AppTextConstants.leads.tr, Iconsax.user_add, AppColors.successColor, route: RouteHelper.getLeadListRoute()),
      _ModuleItem(AppTextConstants.vehicleTypes.tr, Iconsax.bus, AppColors.primaryColor, route: RouteHelper.getVehicleTypeListRoute()),
      _ModuleItem(AppTextConstants.vehicles.tr, Iconsax.bus5, AppColors.infoColor, route: RouteHelper.getVehicleListRoute()),
      _ModuleItem(AppTextConstants.role.tr, Iconsax.shield_tick5, AppColors.slate600, route: RouteHelper.getRoleListRoute()),
      _ModuleItem(AppTextConstants.shifts.tr, Iconsax.clock5, AppColors.warningColor, route: RouteHelper.getShiftListRoute()),
      _ModuleItem(AppTextConstants.staff.tr, Iconsax.people5, AppColors.successColor, route: RouteHelper.getStaffListRoute()),
      _ModuleItem(AppTextConstants.attendance.tr, Iconsax.calendar_tick5, AppColors.indigo500, route: RouteHelper.getAttendanceRoute()),
      _ModuleItem(AppTextConstants.routes.tr, Iconsax.map_15, AppColors.primaryColor, route: RouteHelper.getRouteListRoute()),
      _ModuleItem(AppTextConstants.corporate.tr, Iconsax.building_35, AppColors.infoColor, route: RouteHelper.getCompanyListRoute()),
      _ModuleItem(AppTextConstants.cashbook.tr, Iconsax.money, AppColors.successColor, route: RouteHelper.getCashbookDashboardRoute()),
      _ModuleItem(AppTextConstants.inventory.tr, Iconsax.box5, AppColors.warningColor, route: RouteHelper.getInventoryListRoute()),
      _ModuleItem(AppTextConstants.templates.tr, Iconsax.document_copy5, AppColors.primaryColor, route: RouteHelper.getTemplateListRoute()),
      _ModuleItem(AppTextConstants.reports.tr, Iconsax.chart_215, AppColors.errorColor, route: RouteHelper.getReportsDashboardRoute()),
      _ModuleItem(AppTextConstants.membership.tr, Iconsax.medal_star5, AppColors.infoColor, route: RouteHelper.getMembershipRoute()),
      _ModuleItem(AppTextConstants.profile.tr, Iconsax.profile_circle5, AppColors.successColor, route: RouteHelper.getProfileRoute()),
    ];

    return AppScaffold(
      appBar: AppHeader(
        title: AppTextConstants.more.tr, 
        subtitle: AppTextConstants.exploreAllModules.tr, 
        showBackButton: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return AppCard(
            padding: EdgeInsets.zero,
            onTap: () {
              if (module.title == AppTextConstants.membership.tr) {
                final membershipController = Get.put(MembershipController());
                if (membershipController.activeSubscription.value != null || membershipController.subscriptionHistory.isNotEmpty) {
                  Get.to(() => const ActiveSubscriptionScreen());
                } else {
                  Get.to(() => const MembershipScreen());
                }
                return;
              }
              
              if (module.route != null) {
                Get.toNamed(module.route!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${module.title} ${AppTextConstants.moduleUnderDevelopment.tr}.'),
                    backgroundColor: AppColors.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: module.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(module.icon, color: module.color, size: 28),
                ),
                const SizedBox(height: 12),
                AppText(
                  module.title,
                  style: AppTextStyle.label,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  align: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ModuleItem {
  final String title;
  final IconData icon;
  final Color color;
  final String? route;
  _ModuleItem(this.title, this.icon, this.color, {this.route});
}
