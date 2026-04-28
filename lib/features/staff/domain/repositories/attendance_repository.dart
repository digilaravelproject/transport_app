import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_history_model.dart';

abstract class AttendanceRepository {
  Future<ResponseModel> getAttendance({required String date});
  Future<ResponseModel> saveAttendance({
    required String date,
    required Map<String, dynamic> attendanceData,
  });
  Future<ResponseModel> getAttendanceHistory({
    String? startDate,
    String? endDate,
  });
  Future<ResponseModel> searchAttendanceHistory({required String query});
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> getAttendance({required String date}) async {
    try {
      final endpoint = '/api/v1/attendance?date=$date';

      print('=== ATTENDANCE API CALL ===');
      print('Endpoint: $endpoint');
      print('Date: $date');

      final response = await _apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      print('=== ATTENDANCE API RESPONSE ===');
      print('Success: ${response.isSuccess}');
      print('Status Code: ${response.statusCode}');
      print('Message: ${response.message}');
      print('Body Type: ${response.body.runtimeType}');

      if (response.isSuccess && response.body != null) {
        try {
          List<AttendanceModel> attendanceList = [];
          
          if (response.body is Map<String, dynamic>) {
            final responseData = response.body as Map<String, dynamic>;
            
            if (responseData.containsKey('data') && responseData['data'] is List) {
              final List<dynamic> attendanceData = responseData['data'];
              attendanceList = attendanceData
                  .map((json) => AttendanceModel.fromJson(json))
                  .toList();
              print('Parsed ${attendanceList.length} attendance records');
            } else {
              print('Response data does not contain expected structure');
              print('Available keys: ${responseData.keys.toList()}');
            }
          } else if (response.body is List) {
            final List<dynamic> attendanceData = response.body as List;
            attendanceList = attendanceData
                .map((json) => AttendanceModel.fromJson(json))
                .toList();
            print('Parsed ${attendanceList.length} attendance records from list');
          } else {
            print('Unexpected response body type: ${response.body.runtimeType}');
          }

          print('Successfully fetched ${attendanceList.length} attendance records');
          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message ?? 'Attendance fetched successfully',
            body: attendanceList,
          );
        } catch (e) {
          print('Error processing attendance response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing attendance data: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to fetch attendance',
      );
    } catch (e) {
      print('Error fetching attendance: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching attendance: $e',
      );
    }
  }

  @override
  Future<ResponseModel> saveAttendance({
    required String date,
    required Map<String, dynamic> attendanceData,
  }) async {
    try {
      final endpoint = '/api/v1/attendance';
      final body = {
        'date': date,
        ...attendanceData,
      };

      print('=== SAVE ATTENDANCE API CALL ===');
      print('Endpoint: $endpoint');
      print('Date: $date');
      print('Request body: $body');

      final response = await _apiClient.post(
        endpoint,
        data: body,
        handleError: false,
        showToaster: false,
      );

      print('=== SAVE ATTENDANCE API RESPONSE ===');
      print('Success: ${response.isSuccess}');
      print('Status Code: ${response.statusCode}');
      print('Message: ${response.message}');

      if (response.isSuccess) {
        print('Successfully saved attendance');
        return ResponseModel(
          isSuccess: true,
          statusCode: response.statusCode ?? 200,
          message: response.message ?? 'Attendance saved successfully',
          body: response.body,
        );
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to save attendance',
      );
    } catch (e) {
      print('Error saving attendance: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error saving attendance: $e',
      );
    }
  }

  @override
  Future<ResponseModel> getAttendanceHistory({
    String? startDate,
    String? endDate,
  }) async {
    try {
      String endpoint = '/api/v1/attendance/staff_record';
      
      // Add date parameters if provided
      final queryParams = <String, String>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end'] = endDate;
      }

      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        endpoint += '?$queryString';
      }

      print('=== ATTENDANCE HISTORY API CALL ===');
      print('Endpoint: $endpoint');
      print('Start Date: $startDate');
      print('End Date: $endDate');

      final response = await _apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      print('=== ATTENDANCE HISTORY API RESPONSE ===');
      print('Success: ${response.isSuccess}');
      print('Status Code: ${response.statusCode}');
      print('Message: ${response.message}');

      if (response.isSuccess && response.body != null) {
        try {
          List<AttendanceHistoryModel> historyList = [];
          
          if (response.body is Map<String, dynamic>) {
            final responseData = response.body as Map<String, dynamic>;
            
            if (responseData.containsKey('data') && responseData['data'] is List) {
              final List<dynamic> historyData = responseData['data'];
              historyList = historyData
                  .map((json) => AttendanceHistoryModel.fromJson(json))
                  .toList();
              print('Parsed ${historyList.length} attendance history records');
            } else {
              print('Response data does not contain expected structure');
              print('Available keys: ${responseData.keys.toList()}');
            }
          } else if (response.body is List) {
            final List<dynamic> historyData = response.body as List;
            historyList = historyData
                .map((json) => AttendanceHistoryModel.fromJson(json))
                .toList();
            print('Parsed ${historyList.length} attendance history records from list');
          } else {
            print('Unexpected response body type: ${response.body.runtimeType}');
          }

          print('Successfully fetched ${historyList.length} attendance history records');
          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message ?? 'Attendance history fetched successfully',
            body: historyList,
          );
        } catch (e) {
          print('Error processing attendance history response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing attendance history data: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to fetch attendance history',
      );
    } catch (e) {
      print('Error fetching attendance history: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching attendance history: $e',
      );
    }
  }

  @override
  Future<ResponseModel> searchAttendanceHistory({required String query}) async {
    try {
      final endpoint = '/api/v1/attendance/search?query=$query';

      print('=== ATTENDANCE SEARCH API CALL ===');
      print('Endpoint: $endpoint');
      print('Query: $query');

      final response = await _apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      print('=== ATTENDANCE SEARCH API RESPONSE ===');
      print('Success: ${response.isSuccess}');
      print('Status Code: ${response.statusCode}');

      if (response.isSuccess && response.body != null) {
        try {
          List<AttendanceHistoryModel> historyList = [];
          
          if (response.body is Map<String, dynamic>) {
            final responseData = response.body as Map<String, dynamic>;
            
            if (responseData.containsKey('data') && responseData['data'] is List) {
              final List<dynamic> historyData = responseData['data'];
              historyList = historyData
                  .map((json) => AttendanceHistoryModel.fromJson(json))
                  .toList();
              print('Parsed ${historyList.length} search results');
            }
          } else if (response.body is List) {
            final List<dynamic> historyData = response.body as List;
            historyList = historyData
                .map((json) => AttendanceHistoryModel.fromJson(json))
                .toList();
            print('Parsed ${historyList.length} search results from list');
          }

          print('Successfully fetched ${historyList.length} search results');
          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message ?? 'Search completed successfully',
            body: historyList,
          );
        } catch (e) {
          print('Error processing search response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing search data: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Search failed',
      );
    } catch (e) {
      print('Error searching attendance: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error searching attendance: $e',
      );
    }
  }
}
