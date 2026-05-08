import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../routes/route_helper.dart';
import '../domain/models/lead_model.dart';
import '../controllers/lead_controller.dart';

class FollowUpListScreen extends StatefulWidget {
  const FollowUpListScreen({Key? key}) : super(key: key);

  @override
  State<FollowUpListScreen> createState() => _FollowUpListScreenState();
}

class _FollowUpListScreenState extends State<FollowUpListScreen> {
  final LeadController controller = Get.find<LeadController>();
  late LeadModel lead;

  @override
  void initState() {
    super.initState();
    lead = Get.arguments as LeadModel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await controller.fetchLeadFollowups(lead.id!);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Follow Ups',
        subtitle: lead.customerName,
        onBack: () => Get.back(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getFollowUpRoute(), arguments: lead),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isFollowupsLoading.value && controller.leadFollowups.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.leadFollowups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.calendar_tick, size: 64, color: AppColors.textColorHint.withOpacity(0.5)),
                const SizedBox(height: 16),
                const AppText('No follow ups scheduled', style: AppTextStyle.body),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchLeadFollowups(lead.id!),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.leadFollowups.length,
            itemBuilder: (context, index) {
              final followup = controller.leadFollowups[index];
              final reminderAt = DateTime.parse(followup['reminder_at']);
              final author = followup['author']?['name'] ?? 'User';

              return AppCard(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryColor),
                            const SizedBox(width: 8),
                            AppText(
                              DateFormat('dd MMM, yyyy').format(reminderAt),
                              style: AppTextStyle.body,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryColor),
                            const SizedBox(width: 4),
                            AppText(
                              DateFormat('hh:mm a').format(reminderAt),
                              style: AppTextStyle.body,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    AppText(followup['note'] ?? '', style: AppTextStyle.body),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Iconsax.user, size: 14, color: AppColors.textColorHint),
                        const SizedBox(width: 6),
                        AppText(
                          'Created by $author',
                          style: AppTextStyle.body,
                          fontSize: 12,
                          color: AppColors.textColorHint,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
