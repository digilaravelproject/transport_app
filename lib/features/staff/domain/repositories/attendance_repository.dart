import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<ResponseModel> getAttendance({required String date});
  Future<ResponseModel> saveAttendance({
    required String date,
    required Map<String, dynamic> attendanceData,
  });
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
}
