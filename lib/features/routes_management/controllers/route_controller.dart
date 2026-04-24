import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../domain/models/route_model.dart';

class RouteController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final Dio _googleDio = Dio();
  
  final RxList<RouteModel> _routes = <RouteModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;
  
  final Rxn<RouteModel> selectedRouteDetails = Rxn<RouteModel>();

  // Controllers for Route Creation/Calculation
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final distanceController = TextEditingController();
  final estimatedTimeController = TextEditingController();

  // Location Search
  final RxBool isSearchingLocation = false.obs;
  final RxList<dynamic> predictions = <dynamic>[].obs;

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

  void updateSearch(String query) {
    searchQuery.value = query;
    if (query.isNotEmpty) {
      searchRoutes(query);
    } else {
      fetchRoutes();
    }
  }
  
  void setFilter(String filter) {
    selectedFilter.value = filter;
    fetchRoutes();
  }

  Future<void> searchLocations(String query) async {
    if (query.isEmpty) {
      predictions.clear();
      return;
    }
    isSearchingLocation.value = true;
    try {
      final response = await _googleDio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': AppConstants.googleMapsKey,
        },
      );
      if (response.data['status'] == 'OK') {
        predictions.assignAll(response.data['predictions']);
      } else {
        predictions.clear();
        String error = response.data['error_message'] ?? response.data['status'];
        print('GOOGLE PLACES ERROR: $error');
        
        if (response.data['status'] != 'ZERO_RESULTS') {
          // Using a slight delay to ensure the context is ready
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.context != null) {
              Get.snackbar(
                'Location Search Error', 
                error,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          });
        }
      }
    } catch (e) {
      predictions.clear();
    } finally {
      isSearchingLocation.value = false;
    }
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final response = await _googleDio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry',
          'key': AppConstants.googleMapsKey,
        },
      );
      if (response.data['status'] == 'OK') {
        final location = response.data['result']['geometry']['location'];
        return {
          'lat': location['lat'],
          'lng': location['lng'],
        };
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> calculateRoute() async {
    if (originController.text.isEmpty || destinationController.text.isEmpty) return;

    try {
      final response = await _googleDio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': originController.text,
          'destination': destinationController.text,
          'key': AppConstants.googleMapsKey,
        },
      );

      if (response.data['status'] == 'OK') {
        if (response.data['routes'].isNotEmpty) {
           final leg = response.data['routes'][0]['legs'][0];
          
          // Distance is in meters, convert to km
          double distanceValue = (leg['distance']['value'] / 1000.0);
          distanceController.text = distanceValue.toStringAsFixed(1);
          
          // Duration text (e.g., "3 hours 30 mins")
          estimatedTimeController.text = leg['duration']['text'];
        }
      } else {
        print('DIRECTIONS API ERROR: ${response.data['status']}');
      }
    } catch (e) {
      print('Error calculating route: $e');
    }
  }

  Future<bool> createRoute(Map<String, dynamic> data) async {
    isLoading.value = true;
    final response = await _apiClient.post(AppConstants.createRouteUrl, data: data);
    isLoading.value = false;
    if (response.isSuccess) {
      fetchRoutes(); // Refresh the list
      return true;
    } else {
      Get.snackbar('Error', response.message, backgroundColor: AppColors.errorColor, colorText: Colors.white);
      return false;
    }
  }

  Future<bool> updateRoute(dynamic id, Map<String, dynamic> data) async {
    isLoading.value = true;
    final response = await _apiClient.put(AppConstants.updateRouteUrl(id), data: data);
    isLoading.value = false;
    if (response.isSuccess) {
      fetchRoutes();
      return true;
    } else {
      Get.snackbar('Error', response.message, backgroundColor: AppColors.errorColor, colorText: Colors.white);
      return false;
    }
  }

  Future<void> searchRoutes(String query) async {
    isLoading.value = true;
    final response = await _apiClient.get(AppConstants.searchRoutesUrl(query));
    if (response.isSuccess && response.json != null) {
      final List<dynamic> data = response.json?['data'] ?? [];
      _routes.assignAll(data.map((json) => _parseRoute(json)).toList());
    }
    isLoading.value = false;
  }

  Future<void> fetchRouteDetails(dynamic id) async {
    isLoading.value = true;
    final response = await _apiClient.get(AppConstants.getRouteByIdUrl(id));
    if (response.isSuccess && response.json != null) {
      selectedRouteDetails.value = _parseRoute(response.json?['data']);
    }
    isLoading.value = false;
  }

  Future<void> fetchRoutes() async {
    isLoading.value = true;
    String type = selectedFilter.value.toLowerCase();
    if (type == 'all') type = ''; // Or use 'all' if the API expects it. Based on curl, '' or no param usually means all.
    
    final response = await _apiClient.get(
      AppConstants.getRoutesUrl,
      queryParameters: type.isNotEmpty ? {'type': type} : null,
    );
    
    if (response.isSuccess && response.json != null) {
      final List<dynamic> data = response.json?['data'] ?? [];
      _routes.assignAll(data.map((json) => _parseRoute(json)).toList());
    }
    isLoading.value = false;
  }

  RouteModel _parseRoute(Map<String, dynamic> json) {
    String origin = '';
    String destination = '';
    List<String> viaStops = [];

    // Prioritize 'points' array if available
    if (json['points'] != null && (json['points'] as List).isNotEmpty) {
      final List pointsList = json['points'];
      final firstPoint = pointsList.first;
      
      if (firstPoint is Map) {
        origin = firstPoint['name'] ?? '';
        destination = pointsList.last['name'] ?? '';
        viaStops = pointsList
            .where((p) => p is Map && p['type'] == 'stop')
            .map((p) => p['name'].toString())
            .toList();
      } else {
        // Handle list of strings format
        origin = firstPoint.toString();
        destination = pointsList.last.toString();
        if (pointsList.length > 2) {
          viaStops = pointsList.sublist(1, pointsList.length - 1).map((e) => e.toString()).toList();
        }
      }
    } 
    // Fallback to 'stops' string/list if available
    else if (json['stops'] != null) {
      try {
        final List<dynamic> stopsList = json['stops'] is String 
            ? jsonDecode(json['stops']) 
            : (json['stops'] as List);
            
        if (stopsList.isNotEmpty) {
          origin = stopsList.first.toString();
          destination = stopsList.last.toString();
          if (stopsList.length > 2) {
            viaStops = stopsList.sublist(1, stopsList.length - 1).map((e) => e.toString()).toList();
          }
        }
      } catch (e) {
        // Handle parsing errors gracefully
      }
    }

    return RouteModel(
      id: json['id']?.toString() ?? '',
      routeName: json['name'] ?? '',
      origin: origin,
      destination: destination,
      distanceKm: (json['distance'] ?? 0).toDouble(),
      estimatedTime: json['estimated_time'] ?? '',
      viaStops: viaStops,
      isActive: json['status'] == 'active',
      schedules: (json['schedules'] as List? ?? []).map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{'days': e.toString()};
      }).toList(),
      points: (json['points'] as List? ?? []).map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{'name': e.toString(), 'type': 'stop'};
      }).toList(),
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchRoutes();
  }
}
