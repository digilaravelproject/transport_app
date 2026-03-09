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
import '../../../routes/route_helper.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';

class TripDetailsScreen extends GetView<TripController> {
  const TripDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments ?? controller.trips.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Trip Details',
        subtitle: trip.id != null ? 'ID: #TRP${trip.id}' : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            _buildHeaderCard(trip),
            const SizedBox(height: 16),
            
            // Resource Section
            _buildSectionHeader('Vehicle & Driver'),
            AppCard(
              child: Column(
                children: [
                  _buildInfoRow(Iconsax.bus, 'Vehicle', trip.vehicleNumber ?? 'Not Assigned'),
                  const Divider(height: 24),
                  _buildInfoRow(Iconsax.user, 'Driver', trip.driverName ?? 'Not Assigned'),
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
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Total Expenses', style: AppTextStyle.subheading),
                      AppText('₹ ${trip.totalExpenses}', style: AppTextStyle.heading, color: AppColors.errorColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton.outline(
                    text: 'View All Expenses',
                    onPressed: () => Get.toNamed(RouteHelper.getTripExpenseListRoute(), arguments: trip),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(TripModel trip) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(trip.route, style: AppTextStyle.heading, fontSize: 18),
                  const SizedBox(height: 4),
                  AppText(
                    '${trip.date.day}/${trip.date.month}/${trip.date.year} • ${trip.tripType}',
                    style: AppTextStyle.body,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
              AppStatusChip(status: trip.status.name.capitalizeFirst!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(TripModel trip) {
    return AppCard(
      child: Column(
        children: [
          _buildInfoRow(Iconsax.bus, 'Vehicle', trip.vehicleNumber ?? 'Not Assigned'),
          const Divider(height: 24),
          _buildInfoRow(Iconsax.user, 'Driver', trip.driverName ?? 'Not Assigned'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
            AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.w600),
          ],
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
      {'icon': Iconsax.document_upload, 'label': 'Duty Sheet', 'route': RouteHelper.getDutySheetUploadRoute()},
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
        return AppCard(
          padding: EdgeInsets.zero,
          onTap: () => Get.toNamed(actions[index]['route'] as String),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(actions[index]['icon'] as IconData, color: AppColors.primaryColor, size: 28),
              const SizedBox(height: 8),
              AppText(
                actions[index]['label'] as String,
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
}
