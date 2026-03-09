import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../routes/route_helper.dart';
import '../domain/models/lead_model.dart';
import '../controllers/lead_controller.dart';

class LeadDetailsScreen extends GetView<LeadController> {
  const LeadDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LeadModel lead = Get.arguments ?? controller.leads.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Lead Details',
        onBack: () => Navigator.of(context).pop(),
        trailing: AppStatusChip(status: lead.status),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Customer Info Card ──────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Iconsax.user, size: 30, color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(lead.customerName, style: AppTextStyle.subheading, fontSize: 18),
                            const SizedBox(height: 4),
                            AppText(lead.phone, style: AppTextStyle.body, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionIconButton(
                          icon: Iconsax.call,
                          label: 'Call',
                          color: Colors.green,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionIconButton(
                          icon: Icons.message_rounded,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Trip Details Card ───────────────────────────────────
            _DetailsCard(
              title: 'Trip Details',
              icon: Iconsax.bus,
              children: [
                _InfoRow(label: 'Date', value: '${lead.date.day}/${lead.date.month}/${lead.date.year}'),
                _InfoRow(label: 'Route', value: lead.route),
                _InfoRow(label: 'Duration', value: lead.duration),
                _InfoRow(label: 'Vehicle', value: '${lead.vehicleCount} x ${lead.vehicleType}'),
                if (lead.pickupAddress != null)
                  _InfoRow(label: 'Pickup', value: lead.pickupAddress!),
              ],
            ),

            const SizedBox(height: 20),

            // ── Payment Details Card ────────────────────────────────
            _DetailsCard(
              title: 'Payment Details',
              icon: Iconsax.empty_wallet,
              children: [
                _InfoRow(label: 'Total Amount', value: '₹ ${lead.totalAmount}'),
                _InfoRow(label: 'Advance Paid', value: '₹ ${lead.advancePayment}', valueColor: Colors.green),
                _InfoRow(
                  label: 'Pending Amount', 
                  value: '₹ ${lead.pendingAmount}', 
                  valueColor: lead.pendingAmount > 0 ? Colors.red : Colors.green,
                  isBold: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Actions Grid ────────────────────────────────────────
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                _GridActionButton(
                  icon: Iconsax.edit,
                  label: 'Edit Lead',
                  onTap: () => Get.toNamed(RouteHelper.getEditLeadRoute(), arguments: lead),
                ),
                _GridActionButton(
                  icon: Icons.note_add_rounded,
                  label: 'Add Notes',
                  onTap: () => Get.toNamed(RouteHelper.getLeadNotesRoute(), arguments: lead),
                ),
                _GridActionButton(
                  icon: Icons.notification_add_rounded,
                  label: 'Follow Up',
                  onTap: () => Get.toNamed(RouteHelper.getFollowUpRoute(), arguments: lead),
                ),
                _GridActionButton(
                  icon: Iconsax.add,
                  label: 'Create Trip',
                  onTap: () {},
                ),
                _GridActionButton(
                  icon: Icons.description_rounded,
                  label: 'Quotation',
                  onTap: () => Get.toNamed(RouteHelper.getQuotationPreviewRoute(), arguments: lead),
                ),
                _GridActionButton(
                  icon: Iconsax.receipt_2_1,
                  label: 'Invoice',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailsCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText(title, style: AppTextStyle.subheading, fontSize: 16),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow({required this.label, required this.value, this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary),
          AppText(
            value, 
            style: AppTextStyle.body, 
            color: valueColor ?? AppColors.textColorPrimary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            AppText(label, style: AppTextStyle.body, color: color, fontWeight: FontWeight.w600, fontSize: 13),
          ],
        ),
      ),
    );
  }
}

class _GridActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GridActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: AppColors.primaryColor),
          const SizedBox(height: 8),
          AppText(label, style: AppTextStyle.caption, fontWeight: FontWeight.w600, align: TextAlign.center, fontSize: 11),
        ],
      ),
    );
  }
}
