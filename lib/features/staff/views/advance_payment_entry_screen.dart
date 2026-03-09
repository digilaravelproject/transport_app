import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../routes/route_helper.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class AdvancePaymentEntryScreen extends GetView<StaffController> {
  const AdvancePaymentEntryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments ?? controller.staffList.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Advance Payment',
        subtitle: 'Entry for ${staff.name}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  _buildSummaryRow('Current Salary', '₹ ${staff.salary}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Total Advance Taken', '₹ 25,000', color: Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  const AppInputField(
                    label: 'Advance Amount',
                    hint: '₹ 0.00',
                    icon: Icons.money_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Payment Date',
                    hint: 'DD/MM/YYYY',
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Reason',
                    hint: 'e.g. Personal emergency, Festival advance',
                    icon: Iconsax.info_circle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Advance',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'View Advance History',
              onPressed: () => Get.toNamed(RouteHelper.getAdvanceHistoryRoute(), arguments: staff),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, style: AppTextStyle.body),
        AppText(value, style: AppTextStyle.subheading, color: color, fontWeight: FontWeight.bold),
      ],
    );
  }
}
