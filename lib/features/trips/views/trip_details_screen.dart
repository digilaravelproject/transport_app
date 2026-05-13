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
import '../../../core/constants/app_text_constants.dart';

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
          controller.fetchTripExpenses(tripId!);
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
        return AppScaffold(
          appBar: AppHeader(title: AppTextConstants.tripDetails.tr),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (trip == null) {
        return AppScaffold(
          appBar: AppHeader(title: AppTextConstants.tripDetails.tr),
          body: Center(child: AppText(AppTextConstants.tripNotFound.tr)),
        );
      }

      return AppScaffold(
        appBar: AppHeader(
          title: AppTextConstants.tripDetails.tr,
          subtitle: trip.tripNumber ?? (trip.id != null ? '${AppTextConstants.idLabel.tr}: #TRP${trip.id}' : null),
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
                            AppText(AppTextConstants.deleteTrip.tr, style: AppTextStyle.subheading, fontSize: 20),
                            const SizedBox(height: 12),
                            AppText(
                              AppTextConstants.deleteTripConfirm.tr,
                              style: AppTextStyle.body,
                              color: AppColors.textColorSecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton.outline(
                                    text: AppTextConstants.cancel.tr,
                                    onPressed: () => Get.back(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() => AppButton(
                                    text: AppTextConstants.delete.tr,
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
                  '${AppTextConstants.assignedVehicles.tr} (${trip.vehicleCount} ${AppTextConstants.all.tr})',
                ),
                AppCard(
                  child: Column(
                    children: [
                      // Vehicles Header with Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(AppTextConstants.assignedVehicles.tr, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                          if (trip.assignedVehicles.length < trip.vehicleCount)
                            AppButton(
                              text: AppTextConstants.add.tr,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AppText(AppTextConstants.noVehiclesAssigned.tr, style: AppTextStyle.caption),
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
                                '${AppTextConstants.vehicleLabel.tr} ${index + 1}', 
                                vehicle['registration_number'] ?? 'N/A',
                                trailing: IconButton(
                                  onPressed: () => _showRemoveConfirmation(
                                    title: AppTextConstants.removeVehicle.tr,
                                    message: AppTextConstants.removeVehicleConfirm.tr,
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
                          AppText(AppTextConstants.assignedDrivers.tr, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                          if (trip.assignedDrivers.length < trip.vehicleCount)
                            AppButton(
                              text: AppTextConstants.add.tr,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AppText(AppTextConstants.noDriversAssigned.tr, style: AppTextStyle.caption),
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
                                '${AppTextConstants.driverLabel.tr} ${index + 1}', 
                                driver['name'] ?? 'N/A',
                                trailing: IconButton(
                                  onPressed: () => _showRemoveConfirmation(
                                    title: AppTextConstants.removeDriver.tr,
                                    message: AppTextConstants.removeDriverConfirm.tr,
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
                _buildSectionHeader(AppTextConstants.routeDetails.tr),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      _buildRouteItem(
                        icon: Iconsax.location,
                        title: AppTextConstants.pickup.tr,
                        address: trip.pickupAddress ?? AppTextConstants.notSpecified.tr,
                        isFirst: true,
                      ),
                      if (trip.destinationPoints != null)
                        ...trip.destinationPoints!.map((point) {
                          final isLast = trip.destinationPoints!.last == point;
                          return _buildRouteItem(
                            icon: point['type'] == 'end' ? Iconsax.flag : Iconsax.stop,
                            title: point['type']?.toString().capitalizeFirst ?? AppTextConstants.stop.tr,
                            address: point['name'] ?? AppTextConstants.unknown.tr,
                            isLast: isLast,
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Customer Section
                _buildSectionHeader(AppTextConstants.customerDetails.tr),
                AppCard(
                  child: Column(
                    children: [
                      _buildInfoRow(Iconsax.user_tag, AppTextConstants.fullName.tr, trip.customerName ?? 'N/A'),
                      const Divider(height: 24),
                      _buildInfoRow(Iconsax.call, AppTextConstants.phone.tr, trip.customerPhone ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Payment Section
                _buildSectionHeader(AppTextConstants.paymentSummary.tr),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                       _buildSummaryRow(AppTextConstants.total.tr, '₹ ${trip.totalAmount}'),
                       const SizedBox(height: 8),
                       _buildSummaryRow(AppTextConstants.advancePaid.tr, '₹ ${trip.advanceAmount}', color: Colors.green),
                       const SizedBox(height: 8),
                       _buildSummaryRow(AppTextConstants.pendingBalance.tr, '₹ ${trip.pendingAmount}', color: Colors.red, isBold: true),
                       const SizedBox(height: 12),
                       const Divider(height: 1),
                       const SizedBox(height: 12),
                       if ((trip.pendingAmount ?? 0) > 0)
                         SizedBox(
                           width: double.infinity,
                           child: OutlinedButton.icon(
                             icon: const Icon(Icons.add, color: AppColors.primaryColor),
                             label: AppText('Add Payment', style: AppTextStyle.body, color: AppColors.primaryColor),
                             style: OutlinedButton.styleFrom(
                               side: const BorderSide(color: AppColors.primaryColor),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                               padding: const EdgeInsets.symmetric(vertical: 10),
                             ),
                             onPressed: () => _showAddPaymentSheet(trip.id!, trip.pendingAmount ?? 0),
                           ),
                         ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Actions Grid
                _buildSectionHeader(AppTextConstants.quickActions.tr),
                _buildActionGrid(),
                const SizedBox(height: 16),
                
                // Expense Summary
                _buildSectionHeader(AppTextConstants.expenseSummary.tr),
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
                child: AppStatusChip(status: trip.status.name),
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
      {'icon': Iconsax.bus, 'label': AppTextConstants.vehicles.tr, 'route': RouteHelper.getAssignVehicleRoute()},
      {'icon': Iconsax.user, 'label': AppTextConstants.staff.tr, 'route': RouteHelper.getAssignDriverRoute()},
      {'icon': Iconsax.add, 'label': AppTextConstants.expenses.tr, 'route': RouteHelper.getTripExpenseEntryRoute()},
      {'icon': Iconsax.location, 'label': AppTextConstants.track.tr, 'route': RouteHelper.getTripTrackingRoute()},
      {'icon': Iconsax.document_upload, 'label': AppTextConstants.dutySheet.tr, 'route': RouteHelper.getDutySheetListRoute()},
      {'icon': Icons.description_rounded, 'label': AppTextConstants.invoice.tr, 'route': RouteHelper.getTripInvoiceRoute()},
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
            if (label == AppTextConstants.invoice.tr && tripId != null) {
              final invoiceUrl = "${AppConstants.baseUrl}${AppConstants.getTripInvoiceUrl(tripId)}";
              Get.toNamed(RouteHelper.getPdfViewerRoute(), arguments: {
                'url': invoiceUrl,
                'title': AppTextConstants.invoice.tr,
              });
            } else if (label == AppTextConstants.vehicles.tr) {
              _showAssignedVehiclesBottomSheet();
            } else if (label == AppTextConstants.staff.tr) {
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
          _buildTimelineItem(AppTextConstants.tripScheduled.tr, AppTextConstants.bookingConfirmed.tr, true),
          _buildTimelineItem(AppTextConstants.vehicleAssigned.tr, 'DL 01 AB 1234', true),
          _buildTimelineItem(AppTextConstants.driverAssigned.tr, 'Rajesh Kumar', true),
          _buildTimelineItem(AppTextConstants.tripStart.tr, 'Scheduled at 08:00 AM', false),
          _buildTimelineItem(AppTextConstants.destinationReached.tr, 'Expected by 06:00 PM', false, isLast: true),
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
              AppText(AppTextConstants.totalExpenses.tr, style: AppTextStyle.subheading),
              Obx(() => AppText('₹${controller.totalExpenseAmount}', style: AppTextStyle.heading, color: AppColors.errorColor)),
            ],
          ),
          const SizedBox(height: 12),
          AppButton.outline(
            text: AppTextConstants.viewAllExpenses.tr,
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

  void _showAddPaymentSheet(String tripId, double pendingAmount) {
    final amountController = TextEditingController(text: pendingAmount.toStringAsFixed(0));
    final referenceController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = 'advance';
    const String selectedMode = 'cash';
    DateTime selectedDate = DateTime.now();

    final List<String> types = ['advance', 'partial', 'final', 'refund'];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: AppText('Add Payment', style: AppTextStyle.heading, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  // Amount
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Payment Type
                  AppText('Payment Type', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: types.map((t) => ChoiceChip(
                      label: Text(t[0].toUpperCase() + t.substring(1)),
                      selected: selectedType == t,
                      selectedColor: AppColors.primaryColor,
                      labelStyle: TextStyle(
                        color: selectedType == t ? Colors.white : AppColors.textColorPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setSheetState(() => selectedType = t),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Date Picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) setSheetState(() => selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primaryColor, size: 18),
                          const SizedBox(width: 10),
                          AppText(
                            '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                            style: AppTextStyle.body,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Reference
                  TextField(
                    controller: referenceController,
                    decoration: InputDecoration(
                      labelText: 'Reference (optional)',
                      prefixIcon: const Icon(Icons.receipt_long, color: AppColors.primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Notes
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: const Icon(Icons.notes, color: AppColors.primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text.trim());
                        if (amount == null || amount <= 0) {
                          Get.snackbar('Error', 'Please enter a valid amount',
                              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
                          return;
                        }
                        if (amount > pendingAmount) {
                          Get.snackbar('Error', 'Amount cannot exceed pending balance (₹$pendingAmount)',
                              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
                          return;
                        }
                        final paidOn = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                        Get.back();
                        final success = await controller.addTripPayment(
                          tripId: tripId,
                          amount: amount,
                          type: selectedType,
                          mode: selectedMode,
                          paidOn: paidOn,
                          reference: referenceController.text.trim(),
                          notes: notesController.text.trim(),
                        );
                        if (success) {
                          Get.snackbar(
                            'Success', 'Payment added successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.withOpacity(0.1),
                            colorText: Colors.green,
                          );
                        } else {
                          Get.snackbar('Error', 'Failed to add payment',
                              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
                        }
                      },
                      child: const Text('Save Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
            AppText(AppTextConstants.updateTripStatus.tr, style: AppTextStyle.heading, fontSize: 18),
            const SizedBox(height: 24),
            _buildStatusOption(AppTextConstants.pending.tr, 'pending', trip.status.name == 'pending'),
            _buildStatusOption(AppTextConstants.ongoing.tr, 'ongoing', trip.status.name == 'ongoing'),
            _buildStatusOption(AppTextConstants.completed.tr, 'completed', trip.status.name == 'completed'),
            _buildStatusOption(AppTextConstants.cancelled.tr, 'cancelled', trip.status.name == 'cancelled'),
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
        if (isSelected) return;
        final success = await controller.updateTripStatus(controller.selectedTrip.value!.id!, value);
        if (success) {
          Get.snackbar(
            AppTextConstants.success.tr, 
            '${AppTextConstants.statusUpdatedTo.tr} $label',
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
                      text: AppTextConstants.cancel.tr,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => AppButton(
                      text: AppTextConstants.remove.tr,
                      color: Colors.red,
                      isLoading: controller.isAssigning.value,
                      onPressed: () async {
                        final success = await onConfirm();
                        if (success) {
                          Get.back(); // Close dialog
                          Get.snackbar(
                            AppTextConstants.success.tr, 
                            AppTextConstants.removedSuccessfully.tr,
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
                AppText(AppTextConstants.assignedVehicles.tr, style: AppTextStyle.subheading),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: AppText(AppTextConstants.noVehiclesAssigned.tr, color: AppColors.slate500)),
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
