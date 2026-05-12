import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';
import '../../../core/widgets/app_image_preview.dart';
import '../../../core/constants/app_constants.dart';

class TripExpenseListScreen extends StatefulWidget {
  const TripExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<TripExpenseListScreen> createState() => _TripExpenseListScreenState();
}

class _TripExpenseListScreenState extends State<TripExpenseListScreen> {
  final controller = Get.find<TripController>();
  late TripModel trip;

  @override
  void initState() {
    super.initState();
    trip = Get.arguments ?? controller.trips.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTripExpenses(trip.id.toString());
    });
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Trip Expenses',
        subtitle: trip.tripNumber ?? 'Round Trip',
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tripExpenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.tripExpenses.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildTotalCard(controller.totalExpenseAmount),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchTripExpenses(trip.id.toString()),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.tripExpenses.length,
                  itemBuilder: (context, index) {
                    final e = controller.tripExpenses[index];
                    final amount = double.tryParse(e['amount'].toString()) ?? 0.0;
                    final category = e['category']?.toString() ?? 'Other';
                    final note = e['description']?.toString() ?? '';
                    final dateStr = e['entry_date']?.toString() ?? '';
                    
                    String displayDate = 'N/A';
                    if (dateStr.isNotEmpty) {
                      try {
                        final date = DateTime.parse(dateStr);
                        displayDate = DateFormat('dd MMM, yyyy').format(date);
                      } catch (_) {}
                    }

                    final String path = e['receipt_path']?.toString() ?? '';
                    final String? imageUrl = path.isEmpty 
                        ? null 
                        : (path.startsWith('http') ? path : "${AppConstants.imageBaseUrl}/$path");

                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      onTap: imageUrl != null ? () => AppImagePreview.show(
                        context, 
                        imageUrl: imageUrl, 
                        title: '$category Receipt',
                      ) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _getExpenseIcon(category),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(category, style: AppTextStyle.subheading, fontSize: 16),
                                  if (note.isNotEmpty)
                                    AppText(note, style: AppTextStyle.caption),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AppText('₹$amount', style: AppTextStyle.body, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                                AppText(displayDate, style: AppTextStyle.caption),
                              ],
                            ),
                            if (imageUrl != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Iconsax.eye, color: AppColors.primaryColor, size: 20),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.receipt_2_1, size: 80, color: AppColors.slate300),
          const SizedBox(height: 16),
          AppText('No Expenses Found', style: AppTextStyle.subheading, color: AppColors.slate500),
          const SizedBox(height: 8),
          AppText('No expenses have been recorded for this trip yet.', 
            style: AppTextStyle.caption, align: TextAlign.center),
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
