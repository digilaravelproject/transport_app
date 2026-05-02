import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/corporate_controller.dart';
import '../domain/models/company_model.dart';
import 'dart:io';

class CorporateInvoiceScreen extends GetView<CorporateController> {
  const CorporateInvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CompanyModel company = Get.arguments ?? controller.companies.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Invoice Details',
        rightWidget: IconButton(
          icon: const Icon(Iconsax.document_download, color: AppColors.primaryColor),
          onPressed: () {
             Get.snackbar('Download Started', 'Invoice is being downloaded...', snackPosition: SnackPosition.BOTTOM);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: AppButton.outline(
                  text: 'Share',
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Mark as Paid',
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInvoicePaper(company),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicePaper(CompanyModel company) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('INVOICE', style: AppTextStyle.heading, fontSize: 24, color: AppColors.primaryColor),
                  const SizedBox(height: 8),
                  AppText('INV-2024-001', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                  const SizedBox(height: 4),
                  AppText('Date: 01 May 2024', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  AppText('Due: 15 May 2024', style: AppTextStyle.caption, color: AppColors.errorColor),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.building, color: AppColors.primaryColor, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AppText('Billed To:', style: AppTextStyle.label, color: AppColors.textColorHint),
          const SizedBox(height: 8),
          AppText(company.name, style: AppTextStyle.subheading),
          AppText('Attn: ${company.contactPerson}', style: AppTextStyle.body),
          AppText(company.phone.toString(), style: AppTextStyle.body),
          AppText(company.email.toString(), style: AppTextStyle.body),
          const SizedBox(height: 32),
          const Divider(thickness: 2),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(flex: 3, child: AppText('Description', style: AppTextStyle.caption, color: AppColors.textColorHint)),
              Expanded(child: AppText('Qty', style: AppTextStyle.caption, color: AppColors.textColorHint, textAlign: TextAlign.center)),
              Expanded(child: AppText('Price', style: AppTextStyle.caption, color: AppColors.textColorHint, textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInvoiceLineItem('Daily Commute Transport\n(April 2024) - Bus 50 Seater', '1', '1,50,000'),
          _buildInvoiceLineItem('Extra Weekend Trip\n(15 April 2024)', '1', '15,000'),
          const SizedBox(height: 16),
          const Divider(thickness: 2),
          const SizedBox(height: 16),
          _buildTotalRow('Subtotal', '1,65,000'),
          _buildTotalRow('Tax (18% GST)', '29,700'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Total Due', style: AppTextStyle.subheading, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                const AppText('₹ 1,94,700', style: AppTextStyle.heading, fontSize: 20, color: AppColors.primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AppText('Payment Terms:', style: AppTextStyle.label, color: AppColors.textColorHint),
          const SizedBox(height: 8),
          const AppText('Please pay within 15 days of receiving this invoice. Bank details provided below.', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
          const SizedBox(height: 16),
          const AppCard(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Bank: HDFC Bank', style: AppTextStyle.caption, fontWeight: FontWeight.bold),
                AppText('A/C: 12345678901234', style: AppTextStyle.caption),
                AppText('IFSC: HDFC0001234', style: AppTextStyle.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceLineItem(String desc, String qty, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: AppText(desc, style: AppTextStyle.body)),
          Expanded(child: AppText(qty, style: AppTextStyle.body, textAlign: TextAlign.center)),
          Expanded(child: AppText(price, style: AppTextStyle.body, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary),
          AppText('₹ $value', style: AppTextStyle.subheading),
        ],
      ),
    );
  }
}
