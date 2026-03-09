import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';

class TripExpenseListScreen extends GetView<TripController> {
  const TripExpenseListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments ?? controller.trips.first;

    // Mock expenses
    final expenses = [
      {'type': 'Fuel', 'amount': 4500.0, 'date': 'Today', 'note': 'Full tank at Delhi'},
      {'type': 'Toll', 'amount': 850.0, 'date': 'Today', 'note': 'Gurgaon Toll'},
      {'type': 'Driver Allowance', 'amount': 1200.0, 'date': 'Yesterday', 'note': 'Night stay allowance'},
    ];

    return AppScaffold(
      appBar: AppHeader(
        title: 'Trip Expenses',
        subtitle: trip.route,
      ),
      body: Column(
        children: [
          _buildTotalCard(6550.0),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final e = expenses[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _getExpenseIcon(e['type'] as String),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(e['type'] as String, style: AppTextStyle.subheading, fontSize: 16),
                            AppText(e['note'] as String, style: AppTextStyle.caption),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText('₹${e['amount']}', style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                          AppText(e['date'] as String, style: AppTextStyle.caption),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Total Trip Expense', color: AppColors.white, fontSize: 14),
              SizedBox(height: 4),
              AppText('Cumulative for this trip', color: AppColors.white70, fontSize: 12),
            ],
          ),
          AppText('₹$total', style: AppTextStyle.heading, color: AppColors.white, fontSize: 24),
        ],
      ),
    );
  }

  Widget _getExpenseIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'Fuel':
        icon = Icons.local_gas_station_rounded;
        color = Colors.orange;
        break;
      case 'Toll':
        icon = Icons.toll_rounded;
        color = Colors.blue;
        break;
      case 'Driver Allowance':
        icon = Icons.money_rounded;
        color = Colors.green;
        break;
      default:
        icon = Iconsax.receipt_2_1;
        color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
