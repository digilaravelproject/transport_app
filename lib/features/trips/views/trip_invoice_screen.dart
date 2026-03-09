import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';

class TripInvoiceScreen extends GetView<TripController> {
  const TripInvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments ?? controller.trips.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Trip Invoice',
        subtitle: 'TRP-${trip.id ?? "001"}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('INVOICE', style: AppTextStyle.heading, fontSize: 24, color: AppColors.primaryColor),
                      AppText('#INV-${trip.id ?? "8821"}', style: AppTextStyle.caption),
                    ],
                  ),
                  const Divider(height: 40),
                  _buildInvoiceRow('Trip Route', trip.route),
                  _buildInvoiceRow('Trip Date', '${trip.date.day}/${trip.date.month}/${trip.date.year}'),
                  _buildInvoiceRow('Vehicle', trip.vehicleNumber ?? 'DL 01 AB 1234'),
                  _buildInvoiceRow('Driver', trip.driverName ?? 'Rajesh Kumar'),
                  const Divider(height: 40),
                  _buildAmountRow('Base Fare', 15000.0),
                  _buildAmountRow('Driver Allowance', 1200.0),
                  _buildAmountRow('Tolls & Taxes', 850.0),
                  _buildAmountRow('Service Charge (5%)', 852.5),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Total Amount', style: AppTextStyle.subheading, fontSize: 18),
                      AppText('₹ 17,902.50', style: AppTextStyle.heading, fontSize: 20, color: AppColors.primaryColor),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Download PDF',
                    icon: const Icon(Iconsax.document_download, size: 18),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.outline(
                    text: 'Share',
                    icon: const Icon(Icons.share_rounded, size: 18),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
          AppText(value, style: AppTextStyle.body, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: AppTextStyle.body),
          AppText('₹ $amount', style: AppTextStyle.body, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }
}
