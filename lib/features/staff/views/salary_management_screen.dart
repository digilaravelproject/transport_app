import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class SalaryManagementScreen extends GetView<StaffController> {
  const SalaryManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StaffModel staff = Get.arguments;

    // Fetch salary history on init and when filters change
    everAll([controller.selectedSalaryMonth, controller.selectedSalaryYear], (_) {
      _fetchData(staff.id);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(staff.id);
    });

    return AppScaffold(
      appBar: AppHeader(
        title: 'Salary Management',
        subtitle: staff.name,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.staffSalaryHistory.value == null) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
              }

              final history = controller.staffSalaryHistory.value;
              
              return RefreshIndicator(
                onRefresh: () => _fetchData(staff.id),
                color: AppColors.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(history, staff),
                      const SizedBox(height: 24),
                      const AppText('Financial History', style: AppTextStyle.subheading, fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 12),
                      _buildHistoryList(history),
                    ],
                  ),
                ),
              );
            }),
          ),
          Obx(() {
            final history = controller.staffSalaryHistory.value;
            final selectedMonth = controller.selectedSalaryMonth.value;
            final selectedYear = controller.selectedSalaryYear.value;
            
            // Don't show "Pay Salary" if "All" is selected or if the selected month is already paid
            if (selectedMonth == 'All') return const SizedBox.shrink();

            final months = ['All', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final selectedMonthIdx = months.indexOf(selectedMonth);
            
            final isPaid = history?.records.any((r) => 
              r.year.toString() == selectedYear && 
              (r.month == selectedMonthIdx.toString() || r.month == selectedMonthIdx.toString().padLeft(2, '0')) &&
              r.paymentStatus.toLowerCase() == 'paid'
            ) ?? false;

            if (isPaid) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: AppButton(
                text: 'Pay Salary',
                onPressed: () => _showPaymentModal(staff),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _fetchData(int staffId) async {
    final months = ['All', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    int? month;
    if (controller.selectedSalaryMonth.value != 'All') {
      month = months.indexOf(controller.selectedSalaryMonth.value);
    }
    int year = int.parse(controller.selectedSalaryYear.value);
    
    await controller.fetchStaffSalaryHistory(staffId, month: month, year: year);
  }

  Widget _buildFilterBar() {
    final months = ['All', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 2023 + 1, (index) => (2023 + index).toString()).reversed.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropDownFilter(
              'Month', 
              controller.selectedSalaryMonth, 
              months
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropDownFilter(
              'Year', 
              controller.selectedSalaryYear, 
              years
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDownFilter(String label, RxString value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary, fontSize: 10, fontWeight: FontWeight.bold),
        const SizedBox(height: 4),
        Obx(() => Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.slate200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primaryColor),
              items: items.map((e) => DropdownMenuItem(value: e, child: AppText(e, style: AppTextStyle.body, fontSize: 13))).toList(),
              onChanged: (val) => value.value = val!,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSummaryCard(StaffSalaryHistoryModel? history, StaffModel staff) {
    final summary = history?.summary;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(Iconsax.wallet, color: AppColors.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Monthly Salary', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                    AppText('₹ ${summary?.monthlySalary ?? staff.salary}', style: AppTextStyle.heading, fontSize: 20),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              _buildSummaryStat('Total Paid', '₹ ${summary?.totalPaid ?? 0.0}', AppColors.successColor),
              Container(width: 1, height: 30, color: AppColors.slate200, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _buildSummaryStat('Pending', '₹ ${summary?.totalPending ?? 0.0}', AppColors.errorColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(value, style: AppTextStyle.subheading, fontSize: 16, color: color, fontWeight: FontWeight.bold),
          AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
        ],
      ),
    );
  }

  Widget _buildHistoryList(StaffSalaryHistoryModel? history) {
    if (history == null || history.records.isEmpty) {
      return _buildEmptyState();
    }

    final months = ['All', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final selectedMonthStr = controller.selectedSalaryMonth.value;
    final selectedYearStr = controller.selectedSalaryYear.value;

    // Filter records locally as a fallback to ensure UI sync
    final filteredRecords = history.records.where((record) {
      bool yearMatch = record.year.toString() == selectedYearStr;
      if (!yearMatch) return false;

      if (selectedMonthStr == 'All') return true;
      
      int selectedMonthIdx = months.indexOf(selectedMonthStr);
      // Backend month can be "5" or "05" or "May"
      String recordMonth = record.month.toString();
      bool monthMatch = recordMonth == selectedMonthIdx.toString() || 
                        recordMonth == selectedMonthIdx.toString().padLeft(2, '0');
      
      return monthMatch;
    }).toList();

    if (filteredRecords.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: filteredRecords.map((item) {
        return _SalaryCard(record: item);
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Iconsax.info_circle, size: 40, color: AppColors.slate300),
            const SizedBox(height: 12),
            const AppText('No records for the selected period', style: AppTextStyle.body, color: AppColors.textColorSecondary),
          ],
        ),
      ),
    );
  }

  void _showPaymentModal(StaffModel staff) {
    final pendingAmount = staff.salaryBalance;
    final TextEditingController amountController = TextEditingController(text: pendingAmount.toString());
    final TextEditingController refController = TextEditingController();
    final RxString paymentMode = 'bank'.obs;
    final Rx<DateTime> paidOn = DateTime.now().obs;

    final months = ['All', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    int selectedMonth = controller.selectedSalaryMonth.value == 'All' 
        ? DateTime.now().month 
        : months.indexOf(controller.selectedSalaryMonth.value);
    int selectedYear = int.parse(controller.selectedSalaryYear.value);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Pay Salary', style: AppTextStyle.heading, fontSize: 20),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: [
                    _buildModalBalanceRow('Total Salary', '₹ ${staff.salary}'),
                    const SizedBox(height: 8),
                    _buildModalBalanceRow('Advance Taken', '₹ ${staff.advanceTaken}', color: AppColors.warningColor),
                    const Divider(height: 24),
                    _buildModalBalanceRow('Final Pending', '₹ ${staff.salaryBalance}', color: AppColors.errorColor, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const AppText('Payment Details', style: AppTextStyle.label, fontWeight: FontWeight.bold),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildSelectableTab(
                      'Bank Transfer', 
                      paymentMode.value == 'bank', 
                      () => paymentMode.value = 'bank',
                      Iconsax.bank,
                    )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => _buildSelectableTab(
                      'Cash', 
                      paymentMode.value == 'cash', 
                      () => paymentMode.value = 'cash',
                      Iconsax.money_send,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Paid On', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: Get.context!,
                              initialDate: paidOn.value,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) paidOn.value = date;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Iconsax.calendar, size: 18, color: AppColors.primaryColor),
                                const SizedBox(width: 8),
                                Obx(() => AppText(
                                  '${paidOn.value.day}/${paidOn.value.month}/${paidOn.value.year}',
                                  style: AppTextStyle.body,
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Amount', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                        const SizedBox(height: 8),
                        TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            filled: true,
                            fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate200)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Obx(() => paymentMode.value == 'bank' ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const AppText('Transaction Ref.', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  const SizedBox(height: 8),
                  TextField(
                    controller: refController,
                    decoration: InputDecoration(
                      hintText: 'Enter transaction ID',
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate200)),
                    ),
                  ),
                ],
              ) : const SizedBox.shrink()),
              const SizedBox(height: 32),
              Obx(() => AppButton(
                text: 'Confirm Payment', 
                isLoading: controller.isLoading.value,
                onPressed: () async {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) {
                    CustomSnackbar.showError('Please enter a valid amount');
                    return;
                  }

                  final success = await controller.paySalary(
                    staffId: staff.id,
                    month: selectedMonth,
                    year: selectedYear,
                    amount: amount,
                    paymentMode: paymentMode.value,
                    transactionRef: refController.text.isNotEmpty ? refController.text : null,
                    paidOn: paidOn.value.toIso8601String().split('T')[0],
                  );

                  if (success) {
                    Get.back();
                    _fetchData(staff.id);
                  }
                }
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSelectableTab(String label, bool isSelected, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.slate200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary),
            const SizedBox(width: 8),
            AppText(label, 
              style: AppTextStyle.body, 
              color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalBalanceRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, color: AppColors.textColorSecondary),
        AppText(value, style: AppTextStyle.body, fontSize: 14, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.w600),
      ],
    );
  }
}

class _SalaryCard extends StatelessWidget {
  final SalaryRecord record;
  const _SalaryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final monthName = int.tryParse(record.month) != null ? months[int.parse(record.month)] : record.month;

    return InkWell(
      onTap: () => _showPaymentHistory(record),
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.successColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Iconsax.money_send, color: AppColors.successColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('$monthName ${record.year}', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                      AppText('${record.payments.length} Payments • Monthly Salary', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
                _buildStatusBadge(record.paymentStatus.capitalizeFirst ?? 'Paid'),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Basic Salary', '₹ ${record.basicSalary}'),
            const SizedBox(height: 8),
            _buildDetailRow('Deductions', '₹ ${record.totalDeduction}', color: AppColors.errorColor),
            const SizedBox(height: 8),
            _buildDetailRow('Net Paid', '₹ ${record.netSalary}', color: AppColors.successColor),
            if (record.paidOn != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Paid On', '${record.paidOn!.day}/${record.paidOn!.month}/${record.paidOn!.year}'),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: AppText('View Payment History', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentHistory(SalaryRecord record) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Payment History', style: AppTextStyle.heading, fontSize: 20),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            AppText('${record.payments.length} total transactions found', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            const SizedBox(height: 16),
            if (record.payments.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: AppText('No payment records found', color: AppColors.textColorSecondary),
              ))
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: record.payments.length,
                  itemBuilder: (context, index) {
                    final p = record.payments[index];
                    bool isAdvance = p.type.toLowerCase() == 'advance';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isAdvance ? AppColors.warningColor : AppColors.successColor).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isAdvance ? Iconsax.money_3 : Iconsax.bank,
                              color: isAdvance ? AppColors.warningColor : AppColors.successColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(p.type.capitalizeFirst!, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                                AppText('${p.date.day}/${p.date.month}/${p.date.year} • ${p.paymentMode.capitalizeFirst}', style: AppTextStyle.caption),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppText('₹${p.amount}', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                              if (p.notes != null && p.notes!.isNotEmpty)
                                AppText(p.notes!, style: AppTextStyle.caption, fontSize: 10, color: AppColors.textColorSecondary),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
        AppText(value, style: AppTextStyle.body, fontSize: 13, color: color, fontWeight: FontWeight.w600),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isPaid = status.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.successColor : AppColors.warningColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText(status, style: AppTextStyle.caption, color: isPaid ? AppColors.successColor : AppColors.warningColor, fontWeight: FontWeight.bold),
    );
  }
}
