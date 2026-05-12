import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/route_helper.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({Key? key}) : super(key: key);

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final controller = Get.find<TripController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null) {
      String? tripId;
      if (args is TripModel && args.id != null) {
        controller.selectedTrip.value = args;
        tripId = args.id;
      } else if (args is String) {
        tripId = args;
      }

      if (tripId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchTripDetails(tripId!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final trip = controller.selectedTrip.value;
      final isLoading = controller.isLoading.value;

      if (isLoading && trip == null) {
        return const AppScaffold(
          appBar: AppHeader(title: 'Trip Details'),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (trip == null) {
        return const AppScaffold(
          appBar: AppHeader(title: 'Trip Details'),
          body: Center(child: AppText('Trip not found')),
        );
      }

      return AppScaffold(
        appBar: AppHeader(
          title: 'Trip Details',
          subtitle: trip.tripNumber ?? (trip.id != null ? 'ID: #TRP${trip.id}' : null),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCreateTripRoute(), arguments: trip),
                icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
              ),
              IconButton(
                onPressed: () {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.trash, color: Colors.red, size: 32),
                            ),
                            const SizedBox(height: 24),
                            const AppText('Delete Trip', style: AppTextStyle.subheading, fontSize: 20),
                            const SizedBox(height: 12),
                            AppText(
                              'Are you sure you want to delete this trip? This action cannot be undone.',
                              style: AppTextStyle.body,
                              color: AppColors.textColorSecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton.outline(
                                    text: 'Cancel',
                                    onPressed: () => Get.back(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() => AppButton(
                                    text: 'Delete',
                                    color: Colors.red,
                                    isLoading: controller.isLoading.value,
                                    onPressed: () async {
                                      final success = await controller.deleteTrip(trip.id.toString());
                                      if (success) {
                                        Get.back(); // Close dialog
                                        Get.back(); // Return to list screen
                                      }
                                    },
                                  )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Iconsax.trash, color: Colors.red),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => controller.fetchTripDetails(trip.id!),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Card
                _buildHeaderCard(trip),
                const SizedBox(height: 16),
                
                // Resource Section
                _buildSectionHeader(
                  'Vehicles & Drivers (${trip.vehicleCount} Required)',
                ),
                AppCard(
                  child: Column(
                    children: [
                      // Vehicles Header with Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText('Assigned Vehicles', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                          if (trip.assignedVehicles.length < trip.vehicleCount)
                            AppButton(
                              text: 'Add',
                              onPressed: () => Get.toNamed(RouteHelper.getAssignVehicleRoute(), arguments: trip.id),
                              isFullWidth: false,
                              height: 32,
                              borderRadius: 8,
                              fontSize: 12,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (trip.assignedVehicles.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: AppText('No vehicles assigned yet', style: AppTextStyle.caption),
                        )
                      else
                        ...trip.assignedVehicles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final vehicle = entry.value;
                          final vehicleId = vehicle['id'];
                          return Column(
                            children: [
                              if (index > 0) const Divider(height: 24),
                              _buildInfoRow(
                                Iconsax.bus, 
                                'Vehicle ${index + 1}', 
                                vehicle['registration_number'] ?? 'N/A',
                                trailing: IconButton(
                                  onPressed: () => _showRemoveConfirmation(
                                    title: 'Remove Vehicle',
                                    message: 'Are you sure you want to remove this vehicle from the trip?',
                                    onConfirm: () => controller.removeVehicle(trip.id!, vehicleId),
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                ),
                              ),
                            ],
                          );
                        }),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(height: 1, thickness: 1, color: AppColors.slate100),
                      ),

                      // Drivers Header with Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText('Assigned Drivers', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                          if (trip.assignedDrivers.length < trip.vehicleCount)
                            AppButton(
                              text: 'Add',
                              onPressed: () => Get.toNamed(RouteHelper.getAssignDriverRoute(), arguments: trip.id),
                              isFullWidth: false,
                              height: 32,
                              borderRadius: 8,
                              fontSize: 12,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (trip.assignedDrivers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: AppText('No drivers assigned yet', style: AppTextStyle.caption),
                        )
                      else
                        ...trip.assignedDrivers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final driver = entry.value;
                          final driverId = driver['id'];
                          return Column(
                            children: [
                              if (index > 0) const Divider(height: 24),
                              _buildInfoRow(
                                Iconsax.user, 
                                'Driver ${index + 1}', 
                                driver['name'] ?? 'N/A',
                                trailing: IconButton(
                                  onPressed: () => _showRemoveConfirmation(
                                    title: 'Remove Driver',
                                    message: 'Are you sure you want to remove this driver from the trip?',
                                    onConfirm: () => controller.removeDriver(trip.id!, driverId),
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                ),
                              ),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Route Section
                _buildSectionHeader('Route Details'),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      _buildRouteItem(
                        icon: Iconsax.location,
                        title: 'Pickup',
                        address: trip.pickupAddress ?? 'Not Specified',
                        isFirst: true,
                      ),
                      if (trip.destinationPoints != null)
                        ...trip.destinationPoints!.map((point) {
                          final isLast = trip.destinationPoints!.last == point;
                          return _buildRouteItem(
                            icon: point['type'] == 'end' ? Iconsax.flag : Iconsax.stop,
                            title: point['type']?.toString().capitalizeFirst ?? 'Stop',
                            address: point['name'] ?? 'Unknown',
                            isLast: isLast,
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Customer Section
                _buildSectionHeader('Customer Details'),
                AppCard(
                  child: Column(
                    children: [
                      _buildInfoRow(Iconsax.user_tag, 'Name', trip.customerName ?? 'N/A'),
                      const Divider(height: 24),
                      _buildInfoRow(Iconsax.call, 'Phone', trip.customerPhone ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Payment Section
                _buildSectionHeader('Payment Summary'),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                       _buildSummaryRow('Total Amount', '₹ ${trip.totalAmount}'),
                       const SizedBox(height: 8),
                       _buildSummaryRow('Advance Paid', '₹ ${trip.advanceAmount}', color: Colors.green),
                       const SizedBox(height: 8),
                       _buildSummaryRow('Pending Balance', '₹ ${trip.pendingAmount}', color: Colors.red, isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Actions Grid
                _buildSectionHeader('Quick Actions'),
                _buildActionGrid(),
                const SizedBox(height: 16),
                
                // Expense Summary
                _buildSectionHeader('Expense Summary'),
                _buildExpenseSummary(trip),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCard(TripModel trip) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(trip.route, style: AppTextStyle.heading, fontSize: 18),
                    const SizedBox(height: 4),
                    AppText(
                      '${trip.date.day}/${trip.date.month}/${trip.date.year} • ${trip.tripType}',
                      style: AppTextStyle.body,
                      color: AppColors.textColorSecondary,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      '${trip.vehicleCount} x ${trip.vehicleType}',
                      style: AppTextStyle.body,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showStatusBottomSheet(trip),
                borderRadius: BorderRadius.circular(8),
                child: AppStatusChip(status: trip.status.name.capitalizeFirst!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem({
    required IconData icon,
    required String title,
    required String address,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isFirst ? AppColors.primaryColor : (isLast ? AppColors.errorColor : AppColors.secondaryColor),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: (isFirst ? AppColors.primaryColor : (isLast ? AppColors.errorColor : AppColors.secondaryColor)).withOpacity(0.3),
                    blurRadius: 4,
                  )
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: AppTextStyle.caption,
                color: AppColors.textColorSecondary,
                fontSize: 11,
              ),
              const SizedBox(height: 2),
              AppText(
                address,
                style: AppTextStyle.body,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      {'icon': Iconsax.bus, 'label': 'Vehicle', 'route': RouteHelper.getAssignVehicleRoute()},
      {'icon': Iconsax.user, 'label': 'Driver', 'route': RouteHelper.getAssignDriverRoute()},
      {'icon': Iconsax.add, 'label': 'Expense', 'route': RouteHelper.getTripExpenseEntryRoute()},
      {'icon': Iconsax.location, 'label': 'Track', 'route': RouteHelper.getTripTrackingRoute()},
      {'icon': Iconsax.document_upload, 'label': 'Duty Sheet', 'route': RouteHelper.getDutySheetListRoute()},
      {'icon': Icons.description_rounded, 'label': 'Invoice', 'route': RouteHelper.getTripInvoiceRoute()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        final label = action['label'] as String;
        final tripId = controller.selectedTrip.value?.id;

        return AppCard(
          padding: EdgeInsets.zero,
          onTap: () {
            if (label == 'Invoice' && tripId != null) {
              final invoiceUrl = "${AppConstants.baseUrl}${AppConstants.getTripInvoiceUrl(tripId)}";
              Get.toNamed(RouteHelper.getPdfViewerRoute(), arguments: {
                'url': invoiceUrl,
                'title': 'Invoice Viewer',
              });
            } else if (label == 'Vehicle') {
              _showAssignedVehiclesBottomSheet();
            } else if (label == 'Driver') {
              _showAssignedDriversBottomSheet();
            } else {
              Get.toNamed(action['route'] as String, arguments: tripId);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action['icon'] as IconData, color: AppColors.primaryColor, size: 28),
              const SizedBox(height: 8),
              AppText(
                label,
                style: AppTextStyle.caption,
                fontWeight: FontWeight.w600,
                align: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.w600),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildTimelineSection(TripModel trip) {
    return AppCard(
      child: Column(
        children: [
          _buildTimelineItem('Trip Scheduled', 'Booking confirmed', true),
          _buildTimelineItem('Vehicle Assigned', 'DL 01 AB 1234', true),
          _buildTimelineItem('Driver Assigned', 'Rajesh Kumar', true),
          _buildTimelineItem('Trip Start', 'Scheduled at 08:00 AM', false),
          _buildTimelineItem('Destination reached', 'Expected by 06:00 PM', false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String sub, bool isDone, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isDone ? Iconsax.tick_circle : Icons.radio_button_unchecked_rounded,
              color: isDone ? AppColors.successColor : AppColors.slate300,
              size: 20,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isDone ? AppColors.successColor : AppColors.slate200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(title, style: AppTextStyle.body, fontWeight: isDone ? FontWeight.w600 : FontWeight.normal),
            AppText(sub, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseSummary(TripModel trip) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Total Expenses', style: AppTextStyle.subheading),
              AppText('₹${trip.totalExpenses}', style: AppTextStyle.heading, color: AppColors.errorColor),
            ],
          ),
          const SizedBox(height: 12),
          AppButton.outline(
            text: 'View All Expenses',
            onPressed: () => Get.toNamed(RouteHelper.getTripExpenseListRoute(), arguments: trip),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary),
        AppText(
          value,
          style: AppTextStyle.body,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: color ?? AppColors.textColorPrimary,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: AppText(
        title,
        style: AppTextStyle.subheading,
        fontSize: 14,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _showStatusBottomSheet(TripModel trip) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText('Update Trip Status', style: AppTextStyle.heading, fontSize: 18),
            const SizedBox(height: 24),
            _buildStatusOption('Pending', 'pending', trip.status.name == 'pending'),
            _buildStatusOption('Ongoing', 'ongoing', trip.status.name == 'ongoing'),
            _buildStatusOption('Completed', 'completed', trip.status.name == 'completed'),
            _buildStatusOption('Cancelled', 'cancelled', trip.status.name == 'cancelled'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String label, String value, bool isSelected) {
    return ListTile(
      title: AppText(label, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primaryColor) : null,
      onTap: () async {
        Get.back();
        final success = await controller.updateTripStatus(controller.selectedTrip.value!.id!, value);
        if (success) {
          Get.snackbar(
            'Success', 
            'Status updated to $label',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );
        }
      },
    );
  }

  void _showRemoveConfirmation({
    required String title,
    required String message,
    required Future<bool> Function() onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.minus, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 24),
              AppText(title, style: AppTextStyle.subheading, fontSize: 20),
              const SizedBox(height: 12),
              AppText(
                message,
                style: AppTextStyle.body,
                color: AppColors.textColorSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => AppButton(
                      text: 'Remove',
                      color: Colors.red,
                      isLoading: controller.isAssigning.value,
                      onPressed: () async {
                        final success = await onConfirm();
                        if (success) {
                          Get.back(); // Close dialog
                          Get.snackbar(
                            'Success', 
                            'Removed successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.withOpacity(0.1),
                            colorText: Colors.green,
                          );
                        }
                      },
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignedVehiclesBottomSheet() {
    final trip = controller.selectedTrip.value;
    if (trip == null) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Assigned Vehicles', style: AppTextStyle.subheading),
                IconButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(RouteHelper.getAssignVehicleRoute(), arguments: trip.id);
                  },
                  icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
                ),
              ],
            ),
            const Divider(),
            if (trip.assignedVehicles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: AppText('No vehicles assigned yet', color: AppColors.slate500)),
              )
            else
              ...trip.assignedVehicles.map((v) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.bus, color: AppColors.primaryColor),
                ),
                title: AppText(v['registration_number']?.toString() ?? 'N/A', fontWeight: FontWeight.w600),
                subtitle: AppText(v['type']?.toString() ?? 'Vehicle', style: AppTextStyle.caption),
              )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAssignedDriversBottomSheet() {
    final trip = controller.selectedTrip.value;
    if (trip == null) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Assigned Drivers', style: AppTextStyle.subheading),
                IconButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(RouteHelper.getAssignDriverRoute(), arguments: trip.id);
                  },
                  icon: const Icon(Iconsax.edit, color: AppColors.primaryColor),
                ),
              ],
            ),
            const Divider(),
            if (trip.assignedDrivers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: AppText('No drivers assigned yet', color: AppColors.slate500)),
              )
            else
              ...trip.assignedDrivers.map((d) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.user, color: AppColors.primaryColor),
                ),
                title: AppText(d['name']?.toString() ?? 'N/A', fontWeight: FontWeight.w600),
                subtitle: AppText(d['phone']?.toString() ?? 'Driver', style: AppTextStyle.caption),
              )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
