import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../../../routes/route_helper.dart';
import '../controllers/corporate_controller.dart';
import '../domain/models/company_model.dart';

class CompanyListScreen extends GetView<CorporateController> {
  const CompanyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Vendors',
        subtitle: 'Manage corporate partners',
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getCreateCorporateContractRoute())?.then((_) {
          controller.loadVendors(isRefresh: true);
        }),
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const AppText('Add Vendor', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                AppSearchBar(
                  hint: 'Search by name or contact...',
                  onChanged: (v) => controller.updateSearch(v),
                ),
                const SizedBox(height: 12),
                Obx(() => Row(
                  children: [
                    _buildFilterChip('All', controller.selectedFilter.value == 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Active', controller.selectedFilter.value == 'Active'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Inactive', controller.selectedFilter.value == 'Inactive'),
                  ],
                )
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.companies.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.companies.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.loadVendors(isRefresh: true),
                  child: ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.building_34, size: 64, color: AppColors.slate300),
                            const SizedBox(height: 16),
                            AppText('No vendors found', style: AppTextStyle.body, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.loadVendors(isRefresh: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      controller.loadVendors();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.filteredCompanies.length + (controller.isMoreLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < controller.filteredCompanies.length) {
                        final company = controller.filteredCompanies[index];
                        return _CompanyCard(company: company);
                      } else {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.slate200),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: AppText(
          label,
          style: AppTextStyle.caption,
          color: isSelected ? Colors.white : AppColors.textColorSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final CompanyModel company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final bool isActive = company.isActive;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      onTap: () => Get.toNamed(RouteHelper.getContractDetailsRoute(), arguments: company),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: isActive ? AppColors.successColor : AppColors.slate300,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryLight,
                          child: AppText(
                            company.name.isNotEmpty ? company.name.substring(0, 1).toUpperCase() : 'V',
                            style: AppTextStyle.subheading,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(company.name, style: AppTextStyle.subheading, fontSize: 17, fontWeight: FontWeight.bold),
                              AppText(company.dutyType ?? 'Corporate Partner', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.dialog(
                              AlertDialog(
                                title: const AppText('Change Status', style: AppTextStyle.subheading, fontWeight: FontWeight.bold),
                                content: AppText('Are you sure you want to ${isActive ? 'deactivate' : 'activate'} this vendor?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const AppText('Cancel', color: AppColors.textColorSecondary),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.find<CorporateController>().toggleVendorStatus(company.id);
                                    },
                                    child: AppText(isActive ? 'Deactivate' : 'Activate', 
                                      color: isActive ? AppColors.errorColor : AppColors.successColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: _buildStatusBadge(isActive),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        _buildInfoItem(Iconsax.user, 'Contact', company.contactPerson ?? 'N/A'),
                        const Spacer(),
                        _buildInfoItem(Iconsax.call, 'Phone', company.phone.toString()),
                        const Spacer(),
                       // _buildInfoItem(Iconsax.money, 'Amount', '₹${company.monthlyAmount ?? '0'}'),
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
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
        const SizedBox(height: 2),
        AppText(value, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w600, maxLines: 1),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final Color color = isActive ? AppColors.successColor : AppColors.errorColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Iconsax.tick_circle : Iconsax.close_circle, size: 10, color: color),
          const SizedBox(width: 4),
          AppText(
            isActive ? 'Active' : 'Inactive',
            style: AppTextStyle.caption,
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
