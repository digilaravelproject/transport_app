import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routes/route_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';

  // Mock data for search
  final List<Map<String, dynamic>> _mockData = [
    {'id': '1', 'title': 'Trip #TRS-204', 'type': 'Trip', 'desc': 'Delhi to Shimla • Ongoing', 'icon': Iconsax.routing_2, 'color': AppColors.primaryColor},
    {'id': '2', 'title': 'Trip #TRS-203', 'type': 'Trip', 'desc': 'Noida to Jaipur • Completed', 'icon': Iconsax.tick_circle, 'color': Colors.green},
    {'id': '1', 'title': 'Lead: Rajesh Kumar', 'type': 'Lead', 'desc': 'Inquiry for 12-seater Tempo Traveller', 'icon': Iconsax.user_search, 'color': Colors.orange},
    {'id': '2', 'title': 'Lead: Amit Singh', 'type': 'Lead', 'desc': 'Corporate booking request', 'icon': Iconsax.building_3, 'color': Colors.blue},
    {'id': '1', 'title': 'Vehicle: DL01-7890', 'type': 'Vehicle', 'desc': 'Tata Winger • Active', 'icon': Iconsax.bus, 'color': AppColors.primaryColor},
    {'id': '2', 'title': 'Vehicle: UP16-4421', 'type': 'Vehicle', 'desc': 'Maruti Ertiga • Maintenance', 'icon': Icons.build_rounded, 'color': Colors.redAccent},
    {'id': '1', 'title': 'Driver: Amar Singh', 'type': 'Staff', 'desc': 'On Duty (Trip #TRS-204)', 'icon': Iconsax.profile_circle, 'color': AppColors.primaryColor},
  ];

  List<Map<String, dynamic>> get _filteredResults {
    if (_searchQuery.isEmpty) return [];
    return _mockData.where((item) {
      return item['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item['type'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item['desc'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleNavigation(Map<String, dynamic> item) {
    FocusScope.of(context).unfocus();
    
    final type = item['type'];
    final id = item['id'];
    
    switch (type) {
      case 'Trip':
        Get.toNamed(RouteHelper.getTripDetailsRoute(), arguments: id);
        break;
      case 'Lead':
        Get.toNamed(RouteHelper.getLeadDetailsRoute(), arguments: id);
        break;
      case 'Vehicle':
        Get.toNamed(RouteHelper.getVehicleDetailsRoute(), arguments: id);
        break;
      case 'Staff':
        Get.toNamed(RouteHelper.getStaffDetailsRoute(), arguments: id);
        break;
      default:
        Get.snackbar('Feature', 'Detailed view for $type is coming soon.');
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto focus the search bar when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useScaffold: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(fontSize: 16, color: AppColors.textColorPrimary),
            decoration: InputDecoration(
              hintText: 'Search trips, leads, vehicles...',
              hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
              prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textColorHint, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: _searchQuery.isEmpty ? _buildInitialState() : _buildSearchResults(),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.search_status_1, size: 60, color: AppColors.textColorHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          AppText(
            'Type to search...',
            style: AppTextStyle.subheading,
            color: AppColors.textColorSecondary,
          ),
          const SizedBox(height: 8),
          AppText(
            'Find trips, leads, vehicles, and staff easily.',
            style: AppTextStyle.caption,
            color: AppColors.textColorHint,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredResults;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.document_filter, size: 60, color: AppColors.textColorHint.withOpacity(0.5)),
            const SizedBox(height: 16),
            AppText(
              'No results found',
              style: AppTextStyle.subheading,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 8),
            AppText(
              'Try adjusting your search query.',
              style: AppTextStyle.caption,
              color: AppColors.textColorHint,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _handleNavigation(item),
            borderRadius: BorderRadius.circular(16),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'], color: item['color'], size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          item['title'],
                          style: AppTextStyle.subheading,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          item['desc'],
                          style: AppTextStyle.caption,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AppText(
                      item['type'],
                      style: AppTextStyle.caption,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
