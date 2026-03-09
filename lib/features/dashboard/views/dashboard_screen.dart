import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'home_screen.dart';
import '../../trips/views/trip_list_screen.dart';
import '../../vehicles/views/vehicle_list_screen.dart';
import '../../finance/views/finance_screen.dart';
import 'more_screen.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/widgets/premium_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _currentIndex = 0.obs;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TripListScreen(),
    const VehicleListScreen(),
    const FinanceScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeArea: false,
      extendBody: true,
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Obx(() => IndexedStack(
        index: _currentIndex.value,
        children: _screens,
      )),
      bottomNavigationBar: Obx(() => PremiumBottomNav(
        currentIndex: _currentIndex.value,
        onTap: (index) => _currentIndex.value = index,
        items: const [
          PremiumBottomNavItem(
            icon: Iconsax.home,
            activeIcon: Iconsax.home5,
            label: 'Home',
          ),
          PremiumBottomNavItem(
            icon: Iconsax.routing,
            activeIcon: Iconsax.routing_25,
            label: 'Trips',
          ),
          PremiumBottomNavItem(
            icon: Iconsax.bus,
            activeIcon: Iconsax.bus5,
            label: 'Vehicles',
          ),
          PremiumBottomNavItem(
            icon: Iconsax.wallet,
            activeIcon: Iconsax.wallet5,
            label: 'Finance',
          ),
          PremiumBottomNavItem(
            icon: Iconsax.category,
            activeIcon: Iconsax.category5,
            label: 'More',
          ),
        ],
      )),
    );
  }
}
