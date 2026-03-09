import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../../../routes/route_helper.dart';
import '../controllers/lead_controller.dart';
import '../domain/models/lead_model.dart';

class LeadListScreen extends GetView<LeadController> {
  const LeadListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getCreateLeadRoute()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Fixed AppBar (Back button and Filter)
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.arrow_left_2, color: AppColors.textColorPrimary, size: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.filter, color: AppColors.textColorPrimary, size: 14),
                      SizedBox(width: 4),
                      AppText('Filter', color: AppColors.textColorPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                          'Leads Dashboard',
                          style: AppTextStyle.heading,
                          fontSize: 28,
                          color: AppColors.textColorPrimary,
                        ),
                        SizedBox(height: 4),
                        AppText(
                          'Manage all your inquiries & prospects',
                          style: AppTextStyle.body,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dashboard Stats
                  Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(child: _DashboardStatCard(title: 'Total', value: controller.totalLeads.toString(), color: const Color(0xFF3B82F6), icon: Iconsax.chart_215)),
                        const SizedBox(width: 12),
                        Expanded(child: _DashboardStatCard(title: 'Pending', value: controller.pendingLeads.toString(), color: const Color(0xFFF59E0B), icon: Iconsax.timer_15)),
                        const SizedBox(width: 12),
                        Expanded(child: _DashboardStatCard(title: 'Confirmed', value: controller.confirmedLeads.toString(), color: const Color(0xFF10B981), icon: Iconsax.tick_circle5)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AppSearchBar(
                      hint: 'Search leads...',
                      onChanged: (value) => controller.searchQuery.value = value,
                    ),
                  ),
                  
                  // Filter Chips
                  const SizedBox(height: 12),
                  Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        AppFilterChip(label: 'All', isSelected: controller.selectedFilter.value == 'All', onTap: () => controller.setFilter('All')),
                        AppFilterChip(label: 'Pending', isSelected: controller.selectedFilter.value == 'Pending', onTap: () => controller.setFilter('Pending')),
                        AppFilterChip(label: 'Confirmed', isSelected: controller.selectedFilter.value == 'Confirmed', onTap: () => controller.setFilter('Confirmed')),
                        AppFilterChip(label: 'Cancelled', isSelected: controller.selectedFilter.value == 'Cancelled', onTap: () => controller.setFilter('Cancelled')),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                  
                  // Lead List
                  Obx(() {
                    if (controller.filteredLeads.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: AppText('No leads found', style: AppTextStyle.body),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: controller.filteredLeads.length,
                      itemBuilder: (context, index) {
                        final lead = controller.filteredLeads[index];
                        return _LeadCard(lead: lead);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => Get.toNamed(RouteHelper.getLeadDetailsRoute(), arguments: lead),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      lead.customerName,
                      style: AppTextStyle.subheading,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      lead.phone,
                      style: AppTextStyle.caption,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
              AppStatusChip(status: lead.status),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            children: [
              const Icon(Icons.route_rounded, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText(lead.route, style: AppTextStyle.body, fontSize: 13),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText(
                '${lead.date.day}/${lead.date.month}/${lead.date.year}', 
                style: AppTextStyle.body, 
                fontSize: 13
              ),
              const Spacer(),
              const Icon(Iconsax.bus, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText('${lead.vehicleCount} x ${lead.vehicleType}', style: AppTextStyle.body, fontSize: 13),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.primaryColor, size: 20),
                onSelected: (String result) {
                  Get.find<LeadController>().updateLeadStatus(lead.id!, result);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'Pending', child: AppText('Mark Pending', fontSize: 13)),
                  const PopupMenuItem<String>(value: 'Confirmed', child: AppText('Mark Confirmed', fontSize: 13)),
                  const PopupMenuItem<String>(value: 'Cancelled', child: AppText('Mark Cancelled', fontSize: 13, color: Colors.red)),
                ],
              ),
              IconButton(
                icon: const Icon(Iconsax.call, color: Colors.green, size: 20),
                onPressed: () {},
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'View',
                width: 80,
                height: 32,
                fontSize: 12,
                onPressed: () => Get.toNamed(RouteHelper.getLeadDetailsRoute(), arguments: lead),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _DashboardStatCard({
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
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          AppText(
            value, 
            style: AppTextStyle.heading, 
            fontSize: 22, 
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 4),
          AppText(
            title, 
            style: AppTextStyle.label, 
            fontSize: 12, 
            fontWeight: FontWeight.w600, 
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}

