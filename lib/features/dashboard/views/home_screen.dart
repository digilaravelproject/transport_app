import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../routes/route_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return AppScaffold(
      useScaffold: false,
      safeArea: false,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Obx(() {
                              final userName = authController.currentUser.value?.name ?? 'Partner';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    'Hello',
                                    style: AppTextStyle.heading,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  AppText(
                                    '$userName!',
                                    style: AppTextStyle.heading,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textColorPrimary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            }),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(RouteHelper.getMembershipRoute()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primaryColor, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Iconsax.crown, color: AppColors.primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  AppText(
                                    'PRO',
                                    style: AppTextStyle.caption,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Iconsax.notification, color: AppColors.textColorPrimary, size: 22),
                              onPressed: () => Get.toNamed(RouteHelper.getNotificationsRoute()),
                              padding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        'Keep manage your sales with care.',
                        style: AppTextStyle.caption,
                        color: AppColors.textColorSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      const SizedBox(height: 20),
                      
                      // ── Search Bar ──────────────────────────────────────────
                      GestureDetector(
                        onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Iconsax.search_normal, color: AppColors.textColorPrimary, size: 20),
                              const SizedBox(width: 12),
                              AppText(
                                'Search Update',
                                style: AppTextStyle.caption,
                                color: AppColors.textColorSecondary,
                                fontSize: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16), // Increased top padding from 4 to 24
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Update Card ───────────────────────────────────
                    _HeroCard(),
                    const SizedBox(height: 20),
                    
                    // ── Stats Grid ──────────────────────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95, // Increased height for better padding
                      children: [
                         _StatCard(
                          label: 'Today\'s Trips',
                          value: '08',
                          trend: '+12% from Yesterday',
                          isPositive: true,
                          icon: Iconsax.bus,
                          color: AppColors.primaryColor,
                          onTap: () => Get.toNamed('/trip-list'),
                        ),
                        _StatCard(
                          label: 'Daily Revenue',
                          value: '45.000',
                          trend: '+24% from Last Week',
                          isPositive: true,
                          icon: Iconsax.wallet_3,
                          color: AppColors.primaryColor,
                          isCurrency: true,
                          onTap: () => Get.toNamed('/reports-dashboard'),
                        ),
                        _StatCard(
                          label: 'Pending Leads',
                          value: '124',
                          trend: '+5% this Month',
                          isPositive: true,
                          icon: Iconsax.user_add,
                          color: AppColors.primaryColor,
                          onTap: () => Get.toNamed('/leadList'),
                        ),
                        _StatCard(
                          label: 'Active Vehicles',
                          value: '42',
                          trend: 'All systems normal',
                          isPositive: true,
                          icon: Iconsax.truck_fast,
                          color: AppColors.primaryColor,
                          onTap: () => Get.toNamed('/vehicle-list'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Quick Actions ────────────────────────────────────────
                    const SectionHeader(
                      title: 'Quick Actions',
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          _QuickAction(
                            label: 'Create Lead',
                            icon: Iconsax.user_add,
                            onTap: () => Get.toNamed(RouteHelper.getCreateLeadRoute()),
                          ),
                          _QuickAction(
                            label: 'Create Trip',
                            icon: Iconsax.routing_2,
                            onTap: () => Get.toNamed(RouteHelper.getCreateTripRoute()),
                          ),
                          _QuickAction(
                            label: 'Add Vehicle',
                            icon: Iconsax.bus,
                            onTap: () => Get.toNamed(RouteHelper.getAddVehicleRoute()),
                          ),
                          _QuickAction(
                            label: 'Add Driver',
                            icon: Iconsax.profile_add,
                            onTap: () => Get.toNamed(RouteHelper.getAddStaffRoute()),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Recent Activity ──────────────────────────────────
                    const SectionHeader(
                      title: 'Recent Activity',
                      actionLabel: 'See all',
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                    ),
                    const SizedBox(height: 8),
                    _TransactionTile(
                      title: 'Trip #TRS-204 Started',
                      subtitle: 'DL01-7890 • Amar Singh • 1h ago',
                      icon: Iconsax.bus,
                      status: 'Ongoing',
                      statusColor: const Color(0xFFF59E0B),
                      transactionId: 'TRS-204',
                      onTap: () {},
                    ),
                    _TransactionTile(
                      title: 'Trip #TRS-203 Completed',
                      subtitle: 'UP16-4421 • Rajesh • 4h ago',
                      icon: Iconsax.tick_circle,
                      status: 'Success',
                      statusColor: const Color(0xFF10B981),
                      transactionId: 'TRS-203',
                      onTap: () {},
                    ),
                    _TransactionTile(
                      title: 'New Lead: Rahul Sharma',
                      subtitle: 'Delhi-Manali • Inquiry • 2h ago',
                      icon: Iconsax.user_search,
                      status: 'New',
                      statusColor: AppColors.primaryColor,
                      transactionId: 'LED-451',
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatefulWidget {
  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  String _selectedFilter = 'This Week';

  void _setFilter(String filter) {
    Navigator.of(context).pop(); // Close bottom sheet safely
    setState(() {
      _selectedFilter = filter;
    });
    
    // Optional snackbar
    Get.snackbar(
      'Filter Applied',
      'Showing statistics for $filter',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2E25), // Exact dark green
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444), // Soft vibrant red
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                AppText(
                  'Update',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Filter Statistics',
                              style: AppTextStyle.heading,
                              fontSize: 20,
                            ),
                            const SizedBox(height: 24),
                            _buildFilterOption('Today', Iconsax.calendar_1, _selectedFilter == 'Today', () => _setFilter('Today')),
                            _buildFilterOption('This Week', Iconsax.calendar_2, _selectedFilter == 'This Week', () => _setFilter('This Week')),
                            _buildFilterOption('This Month', Iconsax.calendar, _selectedFilter == 'This Month', () => _setFilter('This Month')),
                            _buildFilterOption('This Year', Iconsax.calendar_tick, _selectedFilter == 'This Year', () => _setFilter('This Year')),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.more_horiz, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Date
            AppText(
              'May 12th 2025',
              color: const Color(0xFF9CA3AF), // Muted grey
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            
            const SizedBox(height: 16), // Increased top margin for text
            
          // Main Statement
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 20, // Reduced from 24
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Outfit', // Or default if Outfit isn't loaded
                height: 1.4, // Increased line-height slightly to compensate
                letterSpacing: -0.3,
              ),
              children: [
                const TextSpan(text: 'Fleet utilization increased '),
                const TextSpan(
                  text: '15%',
                  style: TextStyle(color: Color(0xFF10B981)), // Vibrant neon green
                ),
                TextSpan(text: '\n${_selectedFilter.toLowerCase()}'), // Explicit line break and dynamic text
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action Button
          GestureDetector(
            onTap: () => Get.toNamed(RouteHelper.getReportsDashboardRoute()),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                  'See Statistics',
                  color: const Color(0xFFD1D5DB), // Light grey text
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(width: 6),
                const Icon(Icons.north_east, color: Color(0xFFD1D5DB), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFilterOption(String title, IconData icon, bool isSelected, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary, size: 20),
          const SizedBox(width: 16),
          AppText(
            title,
            style: AppTextStyle.body,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
          ),
          const Spacer(),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;
  final IconData icon;
  final Color color;
  final bool isCurrency;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.icon,
    required this.color,
    this.isCurrency = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                // Removed 3-dot icon as requested
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              label,
              color: AppColors.textColorSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCurrency)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppText(
                      '₹',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (isCurrency) const SizedBox(width: 2),
                Expanded(
                  child: AppText(
                    value,
                    style: AppTextStyle.heading,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isPositive ? Iconsax.trend_up : Iconsax.trend_down,
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AppText(
                    trend,
                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.12),
                    AppColors.primaryColor.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 26),
            ),
            const SizedBox(height: 16),
            AppText(
              label,
              style: AppTextStyle.caption,
              fontWeight: FontWeight.w700,
              align: TextAlign.center,
              fontSize: 13,
              color: AppColors.textColorPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final Color statusColor;
  final String transactionId;
  final VoidCallback onTap;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.statusColor,
    required this.transactionId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF062D24), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    subtitle,
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  status,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
                const SizedBox(height: 4),
                AppText(
                  transactionId,
                  fontSize: 11,
                  color: AppColors.textColorSecondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
