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
import '../controllers/finance_controller.dart';

class CashOutEntryScreen extends StatefulWidget {
  const CashOutEntryScreen({Key? key}) : super(key: key);

  @override
  State<CashOutEntryScreen> createState() => _CashOutEntryScreenState();
}

class _CashOutEntryScreenState extends State<CashOutEntryScreen> {
  final FinanceController controller = Get.find<FinanceController>();
  String _category = 'Fuel';
  String _paymentMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Cash Out (Expense)',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Expense Details', style: AppTextStyle.subheading, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Amount (₹)',
                    hint: '0.00',
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Date',
                    hint: 'DD/MM/YYYY',
                    icon: Iconsax.calendar_1,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown('Category', _category, ['Fuel', 'Maintenance', 'Staff Salary', 'Trip Advance', 'Office Expense', 'Other Expense'], (val) => setState(() => _category = val!)),
                  const SizedBox(height: 16),
                  _buildDropdown('Payment Method', _paymentMethod, ['Cash', 'Bank Transfer', 'UPI', 'Cheque'], (val) => setState(() => _paymentMethod = val!)),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Reference No. / ID',
                    hint: 'e.g. TRP001 or VHC001',
                    icon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Description',
                    hint: 'Add short note...',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Expense',
              color: AppColors.errorColor,
              onPressed: () {
                Get.snackbar('Success', 'Expense recorded successfully!', snackPosition: SnackPosition.BOTTOM);
                Get.back();
              },
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

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
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
          onChanged: onChanged,
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
