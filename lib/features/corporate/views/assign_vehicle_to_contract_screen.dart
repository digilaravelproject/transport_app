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
import '../controllers/corporate_controller.dart';

class AssignVehicleToContractScreen extends StatefulWidget {
  const AssignVehicleToContractScreen({Key? key}) : super(key: key);

  @override
  State<AssignVehicleToContractScreen> createState() => _AssignVehicleToContractScreenState();
}

class _AssignVehicleToContractScreenState extends State<AssignVehicleToContractScreen> {
  final CorporateController controller = Get.find<CorporateController>();
  final List<String> _selectedVehicles = [];

  // Mock list of available vehicles
  final List<Map<String, String>> _availableVehicles = [
    {'id': 'V001', 'no': 'MH 12 AB 1234', 'type': 'Bus (50 Seater)'},
    {'id': 'V002', 'no': 'MH 12 CD 5678', 'type': 'Mini Bus (30 Seater)'},
    {'id': 'V003', 'no': 'MH 12 EF 9012', 'type': 'Tempo Traveller'},
    {'id': 'V004', 'no': 'MH 14 GH 3456', 'type': 'Bus (50 Seater)'},
    {'id': 'V005', 'no': 'MH 14 IJ 7890', 'type': 'Mini Bus'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Assign Vehicles',
        rightWidget: IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: AppColors.textColorPrimary),
          onPressed: () {},
        ),
      ),
      floatingActionButton: _selectedVehicles.isNotEmpty
          ? FloatingActionButton.extended(heroTag: null,
              onPressed: () {
                Get.snackbar('Success', '${_selectedVehicles.length} vehicles assigned.', snackPosition: SnackPosition.BOTTOM);
                Get.back();
              },
              backgroundColor: AppColors.primaryColor,
              label: AppText('Assign ${_selectedVehicles.length} Vehicles', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
              icon: const Icon(Iconsax.tick_circle, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search Vehicle No.',
              onChanged: (v) {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _availableVehicles[index];
                final isSelected = _selectedVehicles.contains(vehicle['id']);
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  child: CheckboxListTile(
                    value: isSelected,
                    activeColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    title: AppText(vehicle['no']!, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                    subtitle: AppText(vehicle['type']!, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.bus, color: AppColors.primaryColor, size: 20),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedVehicles.add(vehicle['id']!);
                        } else {
                          _selectedVehicles.remove(vehicle['id']);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Add some bottom padding so FAB doesn't overlap last item
          const SizedBox(height: 80), 
        ],
      ),
    );
  }
}
