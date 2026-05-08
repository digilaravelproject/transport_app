import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../routes/route_helper.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class AdvanceHistoryScreen extends GetView<StaffController> {
  const AdvanceHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel? staff = Get.arguments as StaffModel?;

    if (staff != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchStaffAdvances(staff.id);
      });
    }

    return AppScaffold(
      appBar: AppHeader(
        title: 'Advance History',
        subtitle: staff?.name ?? 'All Staff',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAdvancePaymentEntryRoute(), arguments: staff),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.staffAdvanceHistory.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = controller.staffAdvanceHistory.value;
        
        return RefreshIndicator(
          onRefresh: () async {
            if (staff != null) {
              await controller.fetchStaffAdvances(staff.id);
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: staff != null ? _buildSummaryCard(history, staff) : const SizedBox.shrink(),
              ),
              Expanded(
                child: history == null || history.advances.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: Get.height * 0.4,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_rounded, size: 64, color: AppColors.textColorHint.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  const AppText('No advance history found', color: AppColors.textColorHint),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: history.advances.length,
                        itemBuilder: (context, index) {
                          final advance = history.advances[index];
                          return _AdvanceCard(advance: advance);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(StaffAdvanceHistoryModel? history, StaffModel staff) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem('Current Salary', '₹${staff.salary}', Colors.white, isLarge: true),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem('Total Adv.', '₹${history?.totalAdvance ?? 0}', Colors.white),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildSummaryItem('Pending', '₹${history?.pendingAmount ?? 0}', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, {bool isLarge = false}) {
    return Expanded(
      flex: isLarge ? 0 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, style: AppTextStyle.caption, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
          const SizedBox(height: 4),
          AppText(value, 
            style: AppTextStyle.heading, 
            fontSize: isLarge ? 28 : 18, 
            color: color, 
            fontWeight: FontWeight.bold
          ),
        ],
      ),
    );
  }
}

class _AdvanceCard extends StatelessWidget {
  final AdvancePayment advance;
  const _AdvanceCard({required this.advance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText(
                            advance.reason.isNotEmpty ? advance.reason : 'General Advance',
                            style: AppTextStyle.subheading,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppText(
                          '₹${advance.amount}',
                          style: AppTextStyle.heading,
                          fontSize: 18,
                          color: AppColors.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildChip(Iconsax.wallet_2, advance.paymentMode?.capitalizeFirst ?? 'Cash'),
                        const SizedBox(width: 8),
                        _buildChip(Iconsax.calendar_1, '${advance.date.day}/${advance.date.month}/${advance.date.year}'),
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

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          AppText(label, style: AppTextStyle.caption, fontSize: 11, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
