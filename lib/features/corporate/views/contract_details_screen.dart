import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/corporate_controller.dart';
import '../domain/models/company_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/corporate_controller.dart';
import '../domain/models/company_model.dart';
import '../../../routes/route_helper.dart';

class ContractDetailsScreen extends GetView<CorporateController> {
  const ContractDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CompanyModel company = Get.arguments ?? controller.companies.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Contract Details',
        subtitle: company.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContractInfo(company),
            const SizedBox(height: 24),
            _buildSectionHeader('Assigned Vehicles', () => Get.toNamed(RouteHelper.getAssignVehicleRoute())),
            _buildAssignedVehicles(),
            const SizedBox(height: 24),
            _buildSectionHeader('Billing History', () {}),
            _buildBillingHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildContractInfo(CompanyModel company) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText('Employee Transport 2024', style: AppTextStyle.subheading, color: AppColors.primaryColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppText('Active', style: AppTextStyle.caption, color: AppColors.successColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildInfoRow('Company', company.name),
          _buildInfoRow('Period', '01 Apr 2024 - 31 Mar 2025'),
          _buildInfoRow('Duty Type', 'Daily Commute'),
          _buildInfoRow('Vehicle Type', 'Bus (50 Seater)'),
          _buildInfoRow('Monthly Amount', '₹ 1,50,000', isAmount: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary),
          AppText(
            value,
            style: isAmount ? AppTextStyle.subheading : AppTextStyle.body,
            color: isAmount ? AppColors.primaryColor : AppColors.textColorPrimary,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(title, style: AppTextStyle.subheading),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.add, size: 16, color: AppColors.primaryColor),
                  SizedBox(width: 4),
                  AppText('Add', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedVehicles() {
    return AppCard(
      child: Column(
        children: [
          _buildVehicleItem('MH 12 AB 1234', 'John Doe'),
          const Divider(height: 1),
          _buildVehicleItem('MH 12 CD 5678', 'Jane Smith', isLast: true),
        ],
      ),
    );
  }

  Widget _buildVehicleItem(String vehicleNo, String driverName, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12, top: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.bus, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(vehicleNo, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText('Driver: $driverName', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.errorColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBillingHistory() {
    return AppCard(
      child: Column(
        children: [
          _buildInvoiceItem('INV-2024-001', '₹ 1,50,000', 'Paid', '01 Apr 2024'),
          const Divider(height: 1),
          _buildInvoiceItem('INV-2024-012', '₹ 1,50,000', 'Pending', '01 May 2024', isLast: true),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(String invNo, String amount, String status, String date, {bool isLast = false}) {
    bool isPaid = status == 'Paid';
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(invNo, style: AppTextStyle.body, fontWeight: FontWeight.bold),
              const SizedBox(height: 4),
              AppText(date, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(amount, style: AppTextStyle.body, fontWeight: FontWeight.bold),
              const SizedBox(height: 4),
              AppText(
                status,
                style: AppTextStyle.caption,
                color: isPaid ? AppColors.successColor : AppColors.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
