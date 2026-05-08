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
import '../../../core/widgets/app_empty_state.dart';

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
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.filter, color: AppColors.textColorPrimary, size: 14),
                        const SizedBox(width: 4),
                        Obx(() => AppText(
                          controller.selectedDateFilter.value == 'All' ? 'Filter' : controller.selectedDateFilter.value,
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
                              title: controller.searchQuery.isNotEmpty ? 'No Results Found' : 'No Leads Found',
                              subtitle: controller.searchQuery.isNotEmpty 
                                  ? 'No leads match your search "${controller.searchQuery.value}".'
                                  : 'Start by creating your first lead to track inquiries.',
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
                const AppText('Filter by Date', style: AppTextStyle.heading, fontSize: 20),
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
                    _dateFilterItem('All', Iconsax.calendar),
                    _dateFilterItem('Today', Iconsax.timer),
                    _dateFilterItem('3 Days', Iconsax.judge),
                    _dateFilterItem('Week', Iconsax.calendar_1),
                    _dateFilterItem('Month', Iconsax.calendar_edit),
                    _dateFilterItem('3 Months', Iconsax.chart_1),
                    _dateFilterItem('6 Months', Iconsax.chart_21),
                    _dateFilterItem('Year', Iconsax.archive_1),
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
                'Custom Range',
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
                  if (lead.id != null) {
                    Get.find<LeadController>().updateLeadStatus(lead.id!, result);
                  }
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
