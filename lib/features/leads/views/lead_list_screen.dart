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
import '../../../core/constants/app_text_constants.dart';
import '../../../core/widgets/app_empty_state.dart';

class LeadListScreen extends GetView<LeadController> {
  const LeadListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getCreateLeadRoute())?.then((value) => controller.fetchLeads(isRefresh: true)),
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
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.arrow_left_2, color: AppColors.textColorPrimary, size: 20),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.fetchLeads(isRefresh: true),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.refresh, color: AppColors.textColorPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showFilterBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.filter, color: AppColors.textColorPrimary, size: 14),
                            const SizedBox(width: 4),
                            Obx(() => AppText(
                              controller.selectedDateFilter.value == 'All' ? AppTextConstants.filter.tr : controller.selectedDateFilter.value,
                              color: AppColors.textColorPrimary, 
                              fontSize: 12, 
                              fontWeight: FontWeight.w600
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchLeads(isRefresh: true),
              color: AppColors.primaryColor,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && 
                      controller.hasMoreData.value && 
                      !controller.isLoading.value && 
                      !controller.isMoreLoading.value) {
                    controller.fetchLeads();
                  }
                  return true;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              AppTextConstants.leadsDashboard.tr,
                              style: AppTextStyle.heading,
                              fontSize: 28,
                              color: AppColors.textColorPrimary,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              AppTextConstants.manageInquiriesProspects.tr,
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
                            Expanded(child: _DashboardStatCard(title: AppTextConstants.total.tr, value: controller.totalLeads.toString(), color: const Color(0xFF3B82F6), icon: Iconsax.chart_215)),
                            const SizedBox(width: 12),
                            Expanded(child: _DashboardStatCard(title: AppTextConstants.pending.tr, value: controller.pendingLeads.toString(), color: const Color(0xFFF59E0B), icon: Iconsax.timer_15)),
                            const SizedBox(width: 12),
                            Expanded(child: _DashboardStatCard(title: AppTextConstants.confirmed.tr, value: controller.confirmedLeads.toString(), color: const Color(0xFF10B981), icon: Iconsax.tick_circle5)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AppSearchBar(
                          hint: AppTextConstants.searchLeadsHint.tr,
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
                            AppFilterChip(label: AppTextConstants.all.tr, isSelected: controller.selectedFilter.value == 'All', onTap: () => controller.setFilter('All')),
                            AppFilterChip(label: AppTextConstants.pending.tr, isSelected: controller.selectedFilter.value == 'Pending', onTap: () => controller.setFilter('Pending')),
                            AppFilterChip(label: AppTextConstants.confirmed.tr, isSelected: controller.selectedFilter.value == 'Confirmed', onTap: () => controller.setFilter('Confirmed')),
                            AppFilterChip(label: AppTextConstants.cancelled.tr, isSelected: controller.selectedFilter.value == 'Cancelled', onTap: () => controller.setFilter('Cancelled')),
                          ],
                        ),
                      )),
                      const SizedBox(height: 16),
                      
                      // Lead List
                      Obx(() {
                        if (controller.isLoading.value && controller.currentPage.value == 1) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (controller.filteredLeads.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: AppEmptyState(
                              title: controller.searchQuery.isNotEmpty ? AppTextConstants.noResultsFound.tr : AppTextConstants.noLeadsFound.tr,
                              subtitle: controller.searchQuery.isNotEmpty 
                                  ? AppTextConstants.noResultsFound.tr
                                  : AppTextConstants.startCreatingLead.tr,
                              icon: controller.searchQuery.isNotEmpty ? Iconsax.search_status : Iconsax.chart_215,
                              actionLabel: null,
                              onActionPressed: null,
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: controller.filteredLeads.length,
                          itemBuilder: (context, index) {
                            final lead = controller.filteredLeads[index];
                            return _LeadCard(lead: lead);
                          },
                        );
                      }),

                      // Load More Spinner
                      Obx(() {
                        if (controller.isMoreLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 100),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return const SizedBox(height: 100);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(AppTextConstants.filterByDate.tr, style: AppTextStyle.heading, fontSize: 20),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: AppColors.textColorPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _dateFilterItem(AppTextConstants.all.tr, Iconsax.calendar),
                    _dateFilterItem(AppTextConstants.today.tr, Iconsax.timer),
                    _dateFilterItem(AppTextConstants.threeDays.tr, Iconsax.judge),
                    _dateFilterItem(AppTextConstants.week.tr, Iconsax.calendar_1),
                    _dateFilterItem(AppTextConstants.month.tr, Iconsax.calendar_edit),
                    _dateFilterItem(AppTextConstants.threeMonths.tr, Iconsax.chart_1),
                    _dateFilterItem(AppTextConstants.sixMonths.tr, Iconsax.chart_21),
                    _dateFilterItem(AppTextConstants.year.tr, Iconsax.archive_1),
                    _customDateRangeItem(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _dateFilterItem(String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedDateFilter.value == label;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          onTap: () {
            controller.setDateFilter(label);
            Get.back();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor.withOpacity(0.3) : AppColors.slate100,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: isSelected ? Colors.white : AppColors.textColorPrimary, size: 16),
                ),
                const SizedBox(width: 12),
                AppText(
                  label,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Iconsax.tick_circle5, color: AppColors.primaryColor, size: 18)
                else
                  const Icon(Iconsax.arrow_right_3, color: AppColors.slate300, size: 16),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _customDateRangeItem(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedDateFilter.value == 'Custom';
      return InkWell(
        onTap: () async {
          Get.back();
          final DateTimeRange? picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textColorPrimary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            controller.setCustomDateRange(picked);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor.withOpacity(0.3) : AppColors.slate100,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                 ),
                child: Icon(Iconsax.calendar_tick, color: isSelected ? Colors.white : AppColors.textColorPrimary, size: 16),
              ),
              const SizedBox(width: 12),
              AppText(
                AppTextConstants.customRange.tr,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Iconsax.tick_circle5, color: AppColors.primaryColor, size: 18)
              else
                const Icon(Iconsax.arrow_right_3, color: AppColors.slate300, size: 16),
            ],
          ),
        ),
      );
    });
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
      onTap: () {
        Get.find<LeadController>().setSelectedLead(lead);
        Get.toNamed(RouteHelper.getLeadDetailsRoute(), arguments: lead)?.then((value) => Get.find<LeadController>().fetchLeads(isRefresh: true, showLoading: false));
      },
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
                    Row(
                      children: [
                        AppText(
                          lead.customerName,
                          style: AppTextStyle.subheading,
                          fontSize: 16,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          lead.leadNo,
                          style: AppTextStyle.caption,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.route_rounded, size: 16, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lead.route.split(' to ').map((location) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(location.trim(), style: AppTextStyle.body, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
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
              AppText('${lead.vehicleCount} x ${lead.vehicleTypeName ?? lead.vehicleType}', style: AppTextStyle.body, fontSize: 13),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.primaryColor, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (String result) async {
                  if (lead.id != null) {
                    await Get.find<LeadController>().updateLeadStatusDetail(lead.id!, result, showLoading: false);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Pending',
                    child: Row(
                      children: [
                        const Icon(Iconsax.timer, size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 12),
                        AppText(AppTextConstants.markPending.tr, fontSize: 13),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Confirmed',
                    child: Row(
                      children: [
                        const Icon(Iconsax.tick_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 12),
                        AppText(AppTextConstants.markConfirmed.tr, fontSize: 13),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Cancelled',
                    child: Row(
                      children: [
                        const Icon(Iconsax.close_circle, size: 16, color: Colors.red),
                        const SizedBox(width: 12),
                        AppText(AppTextConstants.markCancelled.tr, fontSize: 13, color: Colors.red),
                      ],
                    ),
                  ),
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
                text: AppTextConstants.view.tr,
                width: 80,
                height: 32,
                fontSize: 12,
                onPressed: () {
                  Get.find<LeadController>().setSelectedLead(lead);
                  Get.toNamed(RouteHelper.getLeadDetailsRoute(), arguments: lead)?.then((value) => Get.find<LeadController>().fetchLeads(isRefresh: true, showLoading: false));
                },
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
