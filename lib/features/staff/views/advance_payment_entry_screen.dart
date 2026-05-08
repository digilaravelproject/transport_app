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

class AdvancePaymentEntryScreen extends StatefulWidget {
  const AdvancePaymentEntryScreen({Key? key}) : super(key: key);

  @override
  State<AdvancePaymentEntryScreen> createState() => _AdvancePaymentEntryScreenState();
}

class _AdvancePaymentEntryScreenState extends State<AdvancePaymentEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _dateController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'cash';
  late StaffController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffController>();
    _dateController.text = "${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final StaffModel staff = Get.arguments ?? controller.staffList.first;
      
      final success = await controller.recordStaffAdvance(
        staffId: staff.id,
        amount: double.parse(_amountController.text),
        date: "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
        reason: _reasonController.text,
        paymentMode: _paymentMode,
      );

      if (success) {
        Get.back();
      }
    }
  }

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
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Obx(() {
                final totalAdvance = controller.staffAdvanceHistory.value?.totalAdvance ?? 0.0;
                return AppCard(
                  child: Column(
                    children: [
                      _buildSummaryRow('Current Salary', '₹ ${staff.salary}'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Total Advance Taken', '₹ $totalAdvance', color: Colors.orange),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  children: [
                    AppInputField(
                      controller: _amountController,
                      label: 'Advance Amount',
                      hint: '₹ 0.00',
                      icon: Icons.money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter amount';
                        final amount = double.tryParse(value);
                        if (amount == null) return 'Enter a valid number';
                        if (amount <= 0) return 'Amount must be greater than 0';
                        
                        final totalAdvance = controller.staffAdvanceHistory.value?.totalAdvance ?? 0.0;
                        final remaining = (staff.salary) - totalAdvance;
                        if (amount > remaining) {
                          return 'Cannot exceed remaining balance (₹${remaining.toStringAsFixed(2)})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _dateController,
                      label: 'Payment Date',
                      hint: 'DD/MM/YYYY',
                      icon: Iconsax.calendar_1,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please select date';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _reasonController,
                      label: 'Reason',
                      hint: 'e.g. Personal emergency, Festival advance',
                      icon: Iconsax.info_circle,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter reason';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentModeSelection(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                text: 'Save Advance',
                isLoading: controller.isLoading.value,
                onPressed: _submit,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Payment Mode', style: AppTextStyle.body, fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildModeButton('cash', Iconsax.money_send),
            const SizedBox(width: 12),
            _buildModeButton('online', Iconsax.card_send),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(String mode, IconData icon) {
    final isSelected = _paymentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : AppColors.slate50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : AppColors.slate200,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText(
                mode.capitalizeFirst!,
                style: AppTextStyle.body,
                fontSize: 14,
                color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ],
          ),
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
