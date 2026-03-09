import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../controllers/route_controller.dart';
import '../domain/models/route_model.dart';

class AssignRouteScreen extends StatefulWidget {
  const AssignRouteScreen({Key? key}) : super(key: key);

  @override
  State<AssignRouteScreen> createState() => _AssignRouteScreenState();
}

class _AssignRouteScreenState extends State<AssignRouteScreen> {
  final RouteController controller = Get.find<RouteController>();
  RouteModel? _selectedRoute;

  // Mock list of vehicles available for routing
  final List<Map<String, String>> _availableVehicles = [
    {'id': 'V001', 'number': 'MH 12 AB 1234', 'type': 'Bus 50 Seater'},
    {'id': 'V002', 'number': 'MH 14 XY 9876', 'type': 'Bus 32 Seater'},
    {'id': 'V003', 'number': 'MH 12 CD 4567', 'type': 'Mini Bus 20 Seater'},
    {'id': 'V004', 'number': 'MH 14 PQ 1122', 'type': 'SUV 7 Seater'},
  ];
  final List<String> _selectedVehicles = [];

  @override
  void initState() {
    super.initState();
    // Pre-select if navigated from route details
    if (Get.arguments is RouteModel) {
      _selectedRoute = Get.arguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Assign Route',
      ),
      floatingActionButton: _selectedVehicles.isNotEmpty && _selectedRoute != null
          ? FloatingActionButton.extended(heroTag: null,
              onPressed: () {
                Get.snackbar('Success', '${_selectedVehicles.length} vehicles assigned to ${_selectedRoute!.routeName}.', snackPosition: SnackPosition.BOTTOM);
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
            padding: const EdgeInsets.all(20),
            child: _buildRouteDropdown(),
          ),
          if (_selectedRoute != null) ...[
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: AppSearchBar(
                  hint: 'Search vehicle number...',
                  onChanged: (v) {},
                ),
             ),
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                     const AppText('Select Vehicles', style: AppTextStyle.subheading),
                     const Spacer(),
                     AppText('${_selectedVehicles.length} selected', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  ],
                ),
             ),
             Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        title: AppText(vehicle['number']!, style: AppTextStyle.body, fontWeight: FontWeight.bold),
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
             const SizedBox(height: 80), // Prevent FAB overlap
          ] else ...[
             const Expanded(
               child: Center(
                 child: AppText('Please select a route first.', style: AppTextStyle.body, color: AppColors.textColorSecondary),
               ),
             )
          ]
        ],
      ),
    );
  }

  Widget _buildRouteDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Select Route', style: AppTextStyle.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<RouteModel>(
          value: _selectedRoute,
          hint: const Text('Choose a route to assign'),
          items: controller.routes.map((route) {
            return DropdownMenuItem(
              value: route,
              child: Text(route.routeName),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedRoute = val),
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
}
