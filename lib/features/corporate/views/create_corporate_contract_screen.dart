import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/corporate_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/corporate_controller.dart';
import '../domain/models/company_model.dart';

class CreateCorporateContractScreen extends StatefulWidget {
  const CreateCorporateContractScreen({Key? key}) : super(key: key);

  @override
  State<CreateCorporateContractScreen> createState() => _CreateCorporateContractScreenState();
}

class _CreateCorporateContractScreenState extends State<CreateCorporateContractScreen> {
  final CorporateController controller = Get.find<CorporateController>();
  CompanyModel? _selectedCompany;
  String _dutyType = 'Daily Commute';
  String _vehicleType = 'Bus (50 Seater)';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Create Contract',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   AppText('Contract Details', style: AppTextStyle.subheading, color: AppColors.primaryColor),
                   const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Vendor Name',
                    hint: 'Enter vendor name...',
                    icon: Iconsax.building,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Contract Name',
                    hint: 'e.g. Employee Transport 2024',
                    icon: Icons.assignment_rounded,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: const AppInputField(
                          label: 'Start Date',
                          hint: 'DD/MM/YYYY',
                          icon: Iconsax.calendar_1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: const AppInputField(
                          label: 'End Date',
                          hint: 'DD/MM/YYYY',
                          icon: Icons.event_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown('Duty Type', _dutyType, ['Daily Commute', 'Event Transfer', 'Custom Route'], (val) => setState(() => _dutyType = val!)),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdown('Vehicle Type', _vehicleType, ['Bus (50 Seater)', 'Mini Bus (30 Seater)', 'Tempo Traveller'], (val) => setState(() => _vehicleType = val!)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: AppInputField(
                          label: 'Quantity',
                          hint: '0',
                          icon: Iconsax.truck_fast,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Monthly Amount',
                    hint: '₹ 0.00',
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const AppInputField(
                    label: 'Notes',
                    hint: 'Additional terms or notes...',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Contract',
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

  Widget _buildCompanyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Company', style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<CompanyModel>(
          value: _selectedCompany,
          hint: const Text('Select Company'),
          items: controller.companies.map((company) {
            return DropdownMenuItem(
              value: company,
              child: Text(company.name),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCompany = val),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
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
