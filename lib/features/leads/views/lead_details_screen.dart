import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/route_helper.dart';
import '../controllers/lead_controller.dart';
import '../domain/models/lead_model.dart';

class LeadDetailsScreen extends StatefulWidget {
  const LeadDetailsScreen({Key? key}) : super(key: key);

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  final LeadController controller = Get.find<LeadController>();
  late LeadModel lead;

  @override
  void initState() {
    super.initState();
    lead = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lead.id != null) {
        controller.fetchLeadDetails(lead.id!);
      }
    });
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final String url = "whatsapp://send?phone=$phoneNumber";
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Fallback to web link
      final Uri webUri = Uri.parse("https://wa.me/$phoneNumber");
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showStatusBottomSheet(String leadId, String currentStatus) {
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
            const AppText('Update Status', style: AppTextStyle.heading, fontSize: 20),
            const SizedBox(height: 20),
            _statusOption(leadId, 'Pending', Iconsax.timer, const Color(0xFFF59E0B)),
            _statusOption(leadId, 'Confirmed', Iconsax.tick_circle, const Color(0xFF10B981)),
            _statusOption(leadId, 'Cancelled', Iconsax.close_circle, Colors.red),
            const SizedBox(height: 12),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _statusOption(String leadId, String status, IconData icon, Color color) {
    return InkWell(
      onTap: () async {
        final success = await controller.updateLeadStatusDetail(leadId, status);
        if (success) {
          Get.back();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            AppText(status, style: AppTextStyle.body, fontWeight: FontWeight.bold, color: color),
            const Spacer(),
            Icon(Iconsax.arrow_right_3, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String leadId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.trash, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 24),
              const AppText('Delete Lead', style: AppTextStyle.subheading, fontSize: 20),
              const SizedBox(height: 12),
              AppText(
                'Are you sure you want to delete this lead? This action cannot be undone.',
                style: AppTextStyle.body,
                color: AppColors.textColorSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Delete',
                      color: Colors.red,
                      onPressed: () async {
                        Get.back();
                        final success = await controller.deleteLead(leadId);
                        if (success) {
                          Get.back(); // Return to list screen
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Lead Details',
        onBack: () => Get.back(),
        trailing: Obx(() {
          final details = controller.selectedLeadDetails.value;
          final displayLead = details != null ? LeadModel.fromJson(details) : lead;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Iconsax.edit, size: 20, color: AppColors.primaryColor),
                onPressed: () {
                  controller.setSelectedLead(displayLead);
                  Get.toNamed(RouteHelper.getCreateLeadRoute(), arguments: displayLead);
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, size: 20, color: Colors.red),
                onPressed: () => _showDeleteConfirmationDialog(displayLead.id!),
              ),
            ],
          );
        }),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchLeadDetails(lead.id!),
        child: Obx(() {
          if (controller.isDetailsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final details = controller.selectedLeadDetails.value;
          final displayLead = details != null ? LeadModel.fromJson(details) : lead;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText(displayLead.customerName, style: AppTextStyle.subheading, fontSize: 18),
                                    GestureDetector(
                                      onTap: () => _showStatusBottomSheet(displayLead.id!, displayLead.status),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          // decoration: BoxDecoration(
                                          //   color: Colors.white,
                                          //   borderRadius: BorderRadius.circular(20),
                                          //   boxShadow: [
                                          //     BoxShadow(
                                          //       color: Colors.black.withOpacity(0.05),
                                          //       blurRadius: 4,
                                          //       offset: const Offset(0, 2),
                                          //     ),
                                          //   ],
                                          //   border: Border.all(color: AppColors.slate200, width: 1),
                                          // ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppStatusChip(status: displayLead.status),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                AppText(displayLead.phone, style: AppTextStyle.body, color: AppColors.textColorSecondary),
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
                              onTap: () => _makeCall(displayLead.phone),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionIconButton(
                              icon: Icons.message_rounded,
                              label: 'WhatsApp',
                              color: const Color(0xFF25D366),
                              onTap: () => _openWhatsApp(displayLead.phone),
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
                    _InfoRow(label: 'Lead ID', value: displayLead.leadNo),
                    _InfoRow(label: 'Date', value: '${displayLead.date.day}/${displayLead.date.month}/${displayLead.date.year}'),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText('Route', style: AppTextStyle.body, color: AppColors.textColorSecondary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (displayLead.rawPoints != null && displayLead.rawPoints!.isNotEmpty)
                                  ...displayLead.rawPoints!.map((p) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            p['type'] == 'start' 
                                              ? Icons.circle_outlined 
                                              : (p['type'] == 'end' ? Icons.location_on : Icons.circle),
                                            size: 10,
                                            color: AppColors.primaryColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: AppText(
                                              p['name'] ?? 'N/A',
                                              style: AppTextStyle.body,
                                              fontSize: 13,
                                              align: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList()
                                else
                                  AppText(displayLead.route, style: AppTextStyle.body, align: TextAlign.right),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _InfoRow(label: 'Duration', value: displayLead.duration.contains('Day') ? displayLead.duration : '${displayLead.duration} Days'),
                    _InfoRow(label: 'Vehicle', value: '${displayLead.vehicleCount} x ${displayLead.vehicleTypeName ?? displayLead.vehicleType}'),
                    if (displayLead.pickupAddress != null)
                      _InfoRow(label: 'Pickup', value: displayLead.pickupAddress!),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Payment Details Card ────────────────────────────────
                _DetailsCard(
                  title: 'Payment Details',
                  icon: Iconsax.empty_wallet,
                  children: [
                    _InfoRow(label: 'Total Amount', value: '₹ ${displayLead.totalAmount}'),
                    _InfoRow(label: 'Advance Paid', value: '₹ ${displayLead.advancePayment}', valueColor: Colors.green),
                    _InfoRow(
                      label: 'Pending Amount', 
                      value: '₹ ${displayLead.pendingAmount}', 
                      valueColor: displayLead.pendingAmount > 0 ? Colors.red : Colors.green,
                      isBold: true,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Followups ──────────────────────────────────────────
                /*if (controller.leadFollowups.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: AppText('Upcoming Followups', style: AppTextStyle.subheading, fontSize: 16),
                  ),
                  ...controller.leadFollowups.map((f) => _SectionItem(
                    title: f['note'] ?? 'No note',
                    subtitle: f['reminder_at'] != null ? 'Remind at: ${f['reminder_at'].split('T').first}' : 'No date',
                    icon: Iconsax.timer,
                    color: AppColors.warningColor,
                  )),
                  const SizedBox(height: 20),
                ],*/

                // ── Expenses ───────────────────────────────────────────
               /* if (controller.leadExpenses.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: AppText('Trip Expenses', style: AppTextStyle.subheading, fontSize: 16),
                  ),
                  ...controller.leadExpenses.map((e) => _SectionItem(
                    title: e['category'] ?? 'Expense',
                    subtitle: 'Amount: ₹${e['amount']} • ${e['description'] ?? ''}',
                    icon: Iconsax.money_send,
                    color: Colors.redAccent,
                  )),
                  const SizedBox(height: 20),
                ],*/

                // ── Duty Sheets ────────────────────────────────────────
               /* if (controller.leadDutySheets.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: AppText('Duty Sheets', style: AppTextStyle.subheading, fontSize: 16),
                  ),
                  ...controller.leadDutySheets.map((ds) => _SectionItem(
                    title: ds['file_name'] ?? 'Duty Sheet',
                    subtitle: ds['notes'] ?? 'Uploaded on ${ds['created_at'].split('T').first}',
                    icon: Iconsax.document_text,
                    color: AppColors.primaryColor,
                    onTap: () {
                      // Navigate to document viewer if needed
                    },
                  )),
                  const SizedBox(height: 20),
                ],*/

                // ── Lead Notes ─────────────────────────────────────────
                /*if (controller.leadNotes.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: AppText('Recent Notes', style: AppTextStyle.subheading, fontSize: 16),
                  ),
                  ...controller.leadNotes.take(3).map((n) => _SectionItem(
                    title: n.note,
                    subtitle: 'By ${n.userName} • ${n.createdAt.day}/${n.createdAt.month}',
                    icon: Iconsax.note,
                    color: Colors.blueGrey,
                  )),
                  const SizedBox(height: 20),
                ],*/

              //  const SizedBox(height: 12),

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
                      icon: Icons.note_add_rounded,
                      label: 'Add Notes',
                      onTap: () => Get.toNamed(RouteHelper.getLeadNotesRoute(), arguments: displayLead),
                    ),
                    _GridActionButton(
                      icon: Icons.notification_add_rounded,
                      label: 'Follow Up',
                      onTap: () => Get.toNamed(RouteHelper.getFollowUpListRoute(), arguments: displayLead),
                    ),
                    _GridActionButton(
                      icon: Iconsax.add,
                      label: 'Create Trip',
                      onTap: () {},
                    ),
                    _GridActionButton(
                      icon: Icons.description_rounded,
                      label: 'Quotation',
                      onTap: () {
                       // if (displayLead.quotationPath != null && displayLead.quotationPath!.isNotEmpty) {
                          final String fullUrl = AppConstants.getFileUrl(displayLead.quotationPath);
                          Get.toNamed(RouteHelper.getPdfViewerRoute(), arguments: fullUrl);
                        // } else {
                        //   Get.toNamed(RouteHelper.getQuotationPreviewRoute(), arguments: displayLead);
                        // }
                      },
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
          );
        }),
      ),
    );
  }
}

class _SectionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SectionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, style: AppTextStyle.body, fontWeight: FontWeight.bold, fontSize: 13),
                const SizedBox(height: 2),
                AppText(subtitle, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey.shade400),
        ],
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
          Flexible(
            child: AppText(
              value, 
              style: AppTextStyle.body, 
              color: valueColor ?? AppColors.textColorPrimary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              align: TextAlign.right,
            ),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
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
