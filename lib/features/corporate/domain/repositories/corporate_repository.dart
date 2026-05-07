import 'package:http/http.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/multipart.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/corporate_contract_request_model.dart';

abstract class CorporateRepository {
  Future<ResponseModel> createContract(CorporateContractRequestModel request);
  Future<ResponseModel> getVendors({String? search, int page = 1});
  Future<ResponseModel> toggleVendorStatus(String id);
  Future<ResponseModel> getVendorDetails(String id);
  Future<ResponseModel> getAvailableVehicles(String vendorId, {String? search});
  Future<ResponseModel> assignVehicles(String vendorId, List<int> vehicleIds);
  Future<ResponseModel> removeVehicle(String vendorId, String vehicleId);
  Future<ResponseModel> addVendorBill(String vendorId, Map<String, String> body, List<MultipartBody> files);
  Future<ResponseModel> getAvailableDrivers(String vendorId, {String? search});
  Future<ResponseModel> assignDrivers(String vendorId, List<int> staffIds);
  Future<ResponseModel> removeDriver(String vendorId, String driverId);
}

class CorporateRepositoryImpl implements CorporateRepository {
  final ApiClient _apiClient;

  CorporateRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> createContract(CorporateContractRequestModel request) async {
    return await _apiClient.post(
      AppConstants.createVendorUrl,
      data: request.toJson(),
    );
  }

  @override
  Future<ResponseModel> getVendors({String? search, int page = 1}) async {
    Map<String, dynamic> queryParameters = {
      'page': page,
      'per_page': 20,
    };
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    return await _apiClient.get(
      AppConstants.createVendorUrl, // /api/v1/vendors
      queryParameters: queryParameters,
    );
  }

  @override
  Future<ResponseModel> toggleVendorStatus(String id) async {
    return await _apiClient.patch(
      '${AppConstants.createVendorUrl}/$id/toggle-status',
    );
  }

  @override
  Future<ResponseModel> getVendorDetails(String id) async {
    return await _apiClient.get(
      '${AppConstants.createVendorUrl}/$id',
    );
  }

  @override
  Future<ResponseModel> getAvailableVehicles(String vendorId, {String? search}) async {
    Map<String, dynamic> queryParameters = {
      'per_page': 20,
    };
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    return await _apiClient.get(
      '${AppConstants.createVendorUrl}/$vendorId/available-vehicles',
      queryParameters: queryParameters,
    );
  }

  @override
  Future<ResponseModel> assignVehicles(String vendorId, List<int> vehicleIds) async {
    return await _apiClient.post(
      '${AppConstants.createVendorUrl}/$vendorId/assign-vehicles',
      data: {'vehicle_ids': vehicleIds},
    );
  }

  @override
  Future<ResponseModel> removeVehicle(String vendorId, String vehicleId) async {
    return await _apiClient.delete(
      '${AppConstants.createVendorUrl}/$vendorId/remove-vehicle/$vehicleId',
    );
  }

  @override
  Future<ResponseModel> addVendorBill(String vendorId, Map<String, String> body, List<MultipartBody> files) async {
    return await _apiClient.postMultipartData(
      '${AppConstants.createVendorUrl}/$vendorId/bills',
      body,
      files,
      [],
    );
  }

  @override
  Future<ResponseModel> getAvailableDrivers(String vendorId, {String? search}) async {
    Map<String, dynamic> queryParameters = {
      'per_page': 20,
    };
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    return await _apiClient.get(
      '${AppConstants.createVendorUrl}/$vendorId/available-drivers',
      queryParameters: queryParameters,
    );
  }

  @override
  Future<ResponseModel> assignDrivers(String vendorId, List<int> staffIds) async {
    return await _apiClient.post(
      '${AppConstants.createVendorUrl}/$vendorId/assign-drivers',
      data: {'staff_ids': staffIds},
    );
  }

  @override
  Future<ResponseModel> removeDriver(String vendorId, String driverId) async {
    return await _apiClient.delete(
      '${AppConstants.createVendorUrl}/$vendorId/remove-driver/$driverId',
    );
  }
}
