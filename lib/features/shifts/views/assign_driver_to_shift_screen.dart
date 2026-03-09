import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/shift_controller.dart';
import '../domain/models/shift_model.dart';

class AssignDriverToShiftScreen extends StatefulWidget {
  const AssignDriverToShiftScreen({Key? key}) : super(key: key);

  @override
  State<AssignDriverToShiftScreen> createState() => _AssignDriverToShiftScreenState();
}

class _AssignDriverToShiftScreenState extends State<AssignDriverToShiftScreen> {
  final ShiftController controller = Get.find<ShiftController>();
  final List<String> _selectedDrivers = [];

  // Mock list of active drivers available for assignment
  final List<Map<String, String>> _availableDrivers = [
    {'id': 'D001', 'name': 'Ravi Kumar', 'phone': '9876543210'},
    {'id': 'D002', 'name': 'Amit Singh', 'phone': '9123456780'},
    {'id': 'D003', 'name': 'John Doe', 'phone': '9988776655'},
    {'id': 'D004', 'name': 'Jane Smith', 'phone': '9812345670'},
    {'id': 'D005', 'name': 'Mike Johnson', 'phone': '9911223344'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Assign Drivers',
        rightWidget: IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: AppColors.textColorPrimary),
          onPressed: () {},
        ),
      ),
      floatingActionButton: _selectedDrivers.isNotEmpty
          ? FloatingActionButton.extended(heroTag: null,
              onPressed: () {
                Get.snackbar('Success', '${_selectedDrivers.length} drivers assigned to shift.', snackPosition: SnackPosition.BOTTOM);
                Get.back();
              },
              backgroundColor: AppColors.primaryColor,
              label: AppText('Assign ${_selectedDrivers.length} Drivers', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
              icon: const Icon(Iconsax.tick_circle, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search driver name...',
              onChanged: (v) {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableDrivers.length,
              itemBuilder: (context, index) {
                final driver = _availableDrivers[index];
                final isSelected = _selectedDrivers.contains(driver['id']);
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  child: CheckboxListTile(
                    value: isSelected,
                    activeColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    title: AppText(driver['name']!, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                    subtitle: AppText(driver['phone']!, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.user, color: AppColors.primaryColor, size: 20),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedDrivers.add(driver['id']!);
                        } else {
                          _selectedDrivers.remove(driver['id']);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 80), // Prevent FAB overlap
        ],
      ),
    );
  }
}
