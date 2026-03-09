import 'package:get/get.dart';
import '../domain/models/route_model.dart';

class RouteController extends GetxController {
  final RxList<RouteModel> _routes = <RouteModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  List<RouteModel> get routes => _routes;

  List<RouteModel> get filteredRoutes {
    if (searchQuery.value.isEmpty && selectedFilter.value == 'All') {
      return _routes;
    }
    return _routes.where((route) {
      final matchesSearch = route.routeName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          route.origin.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          route.destination.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      bool matchesFilter = true;
      if (selectedFilter.value == 'Active') matchesFilter = route.isActive;
      if (selectedFilter.value == 'Inactive') matchesFilter = !route.isActive;
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateSearch(String query) => searchQuery.value = query;
  void setFilter(String filter) => selectedFilter.value = filter;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    _routes.assignAll([
      RouteModel(
        id: 'RT001',
        routeName: 'Pune - Mumbai (Express)',
        origin: 'Swargate, Pune',
        destination: 'Dadar, Mumbai',
        distanceKm: 150.5,
        estimatedTime: '3h 30m',
        viaStops: ['Lonavala', 'Panvel', 'Vashi'],
        isActive: true,
      ),
      RouteModel(
        id: 'RT002',
        routeName: 'Pune - Nashik (Morning)',
        origin: 'Shivajinagar, Pune',
        destination: 'Nashik CBS',
        distanceKm: 210.0,
        estimatedTime: '5h 00m',
        viaStops: ['Chakan', 'Narayangaon', 'Sangamner'],
        isActive: true,
      ),
      RouteModel(
        id: 'RT003',
        routeName: 'Corporate Tech Park Loop',
        origin: 'Hinjewadi Ph 3',
        destination: 'Kharadi IT Park',
        distanceKm: 35.0,
        estimatedTime: '1h 45m',
        viaStops: ['Wakad', 'Baner', 'Viman Nagar'],
        isActive: false, // Inactive route
      ),
    ]);
  }
}
