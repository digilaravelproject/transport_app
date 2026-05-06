import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/vehicles/controllers/vehicle_type_controller.dart';
import '../../features/vehicles/domain/models/vehicle_type_model.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

/// A reusable dropdown widget that fetches and displays vehicle types
/// from the VehicleTypeController in the format "Name (Capacity)".
///
/// Usage:
/// ```dart
/// VehicleTypeDropdown(
///   selectedId: controller.selectedVehicleTypeId,
///   onChanged: (id, name) {
///     // id = vehicle type id (int?)
///     // name = display string like "Mini Truck (4)"
///   },
/// )
/// ```
class VehicleTypeDropdown extends StatelessWidget {
  final Rxn<int> selectedId;
  final void Function(int? id, String displayName)? onChanged;
  final String label;

  const VehicleTypeDropdown({
    Key? key,
    required this.selectedId,
    this.onChanged,
    this.label = 'Vehicle Type',
  }) : super(key: key);

  /// Ensures the VehicleTypeController is available.
  /// Call this in your screen's init if needed.
  static void ensureController() {
    if (!Get.isRegistered<VehicleTypeController>()) {
      Get.put(VehicleTypeController());
    }
  }

  String _formatDisplayName(VehicleTypeModel type) {
    return '${type.name} (${type.capacity})';
  }

  @override
  Widget build(BuildContext context) {
    // Ensure VehicleTypeController is available
    ensureController();
    final vtController = Get.find<VehicleTypeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.label),
        const SizedBox(height: 8),
        Obx(() {
          final types = vtController.vehicleTypes;
          final loading = vtController.isLoading.value;
          final currentId = selectedId.value;

          // Check if current selected ID exists in the list
          final selectedType = currentId != null
              ? types.firstWhereOrNull((t) => t.id == currentId)
              : null;

          if (loading && types.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  AppText('Loading vehicle types...', style: AppTextStyle.body, fontSize: 14),
                ],
              ),
            );
          }

          if (types.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const AppText(
                'No vehicle types available',
                style: AppTextStyle.body,
                fontSize: 14,
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedType != null ? selectedType.id : null,
                isExpanded: true,
                hint: const AppText('Select Vehicle Type', style: AppTextStyle.body, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: (int? newId) {
                  if (newId != null) {
                    selectedId.value = newId;
                    final selected = types.firstWhereOrNull((t) => t.id == newId);
                    if (selected != null && onChanged != null) {
                      onChanged!(newId, _formatDisplayName(selected));
                    }
                  }
                },
                items: types.map((VehicleTypeModel type) {
                  return DropdownMenuItem<int>(
                    value: type.id,
                    child: AppText(
                      _formatDisplayName(type),
                      style: AppTextStyle.body,
                      fontSize: 14,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }
}
