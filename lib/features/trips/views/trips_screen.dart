import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/status_chip.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppHeader(
          title: 'Trips',
          subtitle: 'Track and manage your fleet',
          showBackButton: false,
          bottom: TabBar(
            indicatorColor: AppColors.primaryColor,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textColorHint,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TripsList(status: ChipStatus.active),
            const AppEmptyState(
              icon: Iconsax.clock,
              title: 'No Completed Trips',
              subtitle: 'Past trips will appear here once finalized.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsList extends StatelessWidget {
  final ChipStatus status;
  const _TripsList({required this.status});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 0, // Empty for now to show empty state if needed
      itemBuilder: (context, index) => Container(),
    );
  }
}
