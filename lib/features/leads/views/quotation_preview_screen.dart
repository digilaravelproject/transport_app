import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../routes/route_helper.dart';
import '../domain/models/lead_model.dart';
import '../controllers/lead_controller.dart';

class QuotationPreviewScreen extends GetView<LeadController> {
  const QuotationPreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LeadModel lead = Get.arguments ?? controller.leads.first;

    return AppScaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppHeader(
        title: 'Quotation Preview',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Quotation Card (Mimicking a document)
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('DigiEmperor', style: AppTextStyle.heading, fontSize: 20, color: AppColors.primaryColor),
                      AppText('QTN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', style: AppTextStyle.caption),
                    ],
                  ),
                  const Divider(height: 32),
                  _QuotationRow(label: 'Agency', value: 'Fleet Management SaaS'),
                  _QuotationRow(label: 'Customer', value: lead.customerName),
                  _QuotationRow(label: 'Trip Route', value: lead.route),
                  _QuotationRow(label: 'Trip Date', value: '${lead.date.day}/${lead.date.month}/${lead.date.year}'),
                  _QuotationRow(label: 'Duration', value: lead.duration),
                  _QuotationRow(label: 'Vehicle', value: '${lead.vehicleCount} x ${lead.vehicleType}'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Total Price', style: AppTextStyle.subheading, fontSize: 16),
                        AppText('₹ ${lead.totalAmount}', style: AppTextStyle.heading, fontSize: 22, color: AppColors.primaryColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AppText(
                    'Terms & Conditions:\n• 20% advance for booking confirmation.\n• Remaining payload at trip start.\n• Cancellation fees apply.',
                    style: AppTextStyle.caption,
                    fontSize: 10,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _OutlineActionButton(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Download PDF',
                  onTap: () => Get.toNamed(RouteHelper.getPdfViewerRoute()),
                ),
                _OutlineActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share PDF',
                  onTap: () {},
                ),
                _OutlineActionButton(
                  icon: Icons.message_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {},
                ),
                _OutlineActionButton(
                  icon: Iconsax.sms,
                  label: 'Email',
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            AppButton(
              text: 'Confirm Booking',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotationRow extends StatelessWidget {
  final String label;
  final String value;
  const _QuotationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, style: AppTextStyle.caption, color: AppColors.textColorHint),
          const SizedBox(height: 4),
          AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _OutlineActionButton({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: themeColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: themeColor.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: themeColor),
            const SizedBox(width: 10),
            AppText(label, style: AppTextStyle.body, color: themeColor, fontWeight: FontWeight.w600, fontSize: 13),
          ],
        ),
      ),
    );
  }
}
