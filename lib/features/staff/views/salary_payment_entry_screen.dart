import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/staff_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/models/staff_model.dart';

class SalaryPaymentEntryScreen extends StatefulWidget {
  const SalaryPaymentEntryScreen({Key? key}) : super(key: key);

  @override
  State<SalaryPaymentEntryScreen> createState() => _SalaryPaymentEntryScreenState();
}

class _SalaryPaymentEntryScreenState extends State<SalaryPaymentEntryScreen> {
  final StaffModel staff = Get.arguments ?? Get.find<StaffController>().staffList.first;
  String _paymentMethod = 'Bank Transfer';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Salary Payment',
        subtitle: staff.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  _buildSummaryRow('Base Salary', '₹ ${staff.salary}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Pending Balance', '₹ ${staff.salaryBalance}', color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                   const AppInputField(
                    label: 'Payment Amount',
                    hint: '₹ 0.00',
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Payment Date',
                    hint: 'DD/MM/YYYY',
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Payment Method',
                    _paymentMethod,
                    ['Bank Transfer', 'Cash', 'Cheque', 'UPI'],
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Reference / Transaction ID',
                    hint: 'Enter Ref No.',
                    icon: Iconsax.receipt_2_1,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Notes',
                    hint: 'Salary for March 2024...',
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Confirm Payment',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'Cancel',
              onPressed: () => Get.back(),
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

  Widget _buildDropdown(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (val) => setState(() => _paymentMethod = val!),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}
