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
import '../domain/models/transaction_request_model.dart';
import 'package:intl/intl.dart';

class CashOutEntryScreen extends StatefulWidget {
  const CashOutEntryScreen({Key? key}) : super(key: key);

  @override
  State<CashOutEntryScreen> createState() => _CashOutEntryScreenState();
}

class _CashOutEntryScreenState extends State<CashOutEntryScreen> {
  final FinanceController controller = Get.find<FinanceController>();
  final _formKey = GlobalKey<FormState>();
  
  String _category = 'Fuel';
  String _paymentMethod = 'UPI';
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _refController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        Get.snackbar('Error', 'Please enter a valid amount', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      final request = TransactionRequestModel(
        type: 'expense',
        amount: amount,
        entryDate: _dateController.text, // Assume YYYY-MM-DD
        category: _category.replaceAll(' ', '_').toLowerCase(),
        paymentMethod: _paymentMethod.replaceAll(' ', '_').toLowerCase(),
        referenceNumber: _refController.text,
        description: _descController.text,
      );

      await controller.saveTransaction(request);
    } else {
      Get.snackbar('Error', 'Please fill in all required fields', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Cash Out (Expense)',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Expense Details', style: AppTextStyle.subheading, color: AppColors.errorColor),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _amountController,
                      label: 'Amount (₹)',
                      hint: '0.00',
                      icon: Iconsax.card,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Amount is required';
                        if (double.tryParse(value) == null) return 'Invalid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: AppInputField(
                          controller: _dateController,
                          label: 'Date',
                          hint: 'YYYY-MM-DD',
                          icon: Iconsax.calendar_1,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Date is required';
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown('Category', _category, ['Fuel', 'Maintenance', 'Staff Salary', 'Trip Advance', 'Office Expense', 'Other Expense'], (val) => setState(() => _category = val!)),
                    const SizedBox(height: 16),
                    _buildDropdown('Payment Method', _paymentMethod, ['Cash', 'Bank Transfer', 'UPI', 'Cheque'], (val) => setState(() => _paymentMethod = val!)),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _refController,
                      label: 'Reference No. / ID',
                      hint: 'e.g. TRP001 or VHC001',
                      icon: Icons.tag_rounded,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _descController,
                      label: 'Description',
                      hint: 'Add short note...',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Description is required';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                text: controller.isLoading.value ? 'Saving...' : 'Save Expense',
                color: AppColors.errorColor,
                onPressed: controller.isLoading.value ? () {} : _saveExpense,
              )),
              const SizedBox(height: 12),
              AppButton.outline(
                text: 'Cancel',
                onPressed: () => Get.back(),
              ),
            ],
          ),
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
