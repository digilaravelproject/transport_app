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
        title: 'Companies',
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getCreateCorporateContractRoute()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const AppText('Add Company', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: AppSearchBar(
              hint: 'Search by name or contact...',
              onChanged: (v) => controller.updateSearch(v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
              children: [
                AppFilterChip(
                  label: 'All',
                  isSelected: controller.selectedFilter.value == 'All',
                  onTap: () => controller.setFilter('All'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'Active',
                  isSelected: controller.selectedFilter.value == 'Active',
                  onTap: () => controller.setFilter('Active'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'No Contracts',
                  isSelected: controller.selectedFilter.value == 'No Contracts',
                  onTap: () => controller.setFilter('No Contracts'),
                ),
              ],
            )),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.filteredCompanies.isEmpty) {
                return const Center(child: AppText('No companies found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredCompanies.length,
                itemBuilder: (context, index) {
                  final company = controller.filteredCompanies[index];
                  return _CompanyCard(company: company);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final CompanyModel company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed(RouteHelper.getContractDetailsRoute(), arguments: company),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(company.name, style: AppTextStyle.subheading, fontSize: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: company.activeContracts > 0 ? AppColors.successColor.withOpacity(0.1) : AppColors.slate200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  'Contracts: ${company.activeContracts}',
                  style: AppTextStyle.caption,
                  color: company.activeContracts > 0 ? AppColors.successColor : AppColors.textColorHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Iconsax.user, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText('Contact: ${company.contactPerson}', style: AppTextStyle.body),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.call, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText('Phone: ${company.phone}', style: AppTextStyle.body),
            ],
          ),
        ],
      ),
    );
  }
}
