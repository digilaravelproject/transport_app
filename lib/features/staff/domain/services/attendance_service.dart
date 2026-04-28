import '../../../../core/services/network/response_model.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceUseCase {
  final AttendanceRepository _repository;

  GetAttendanceUseCase(this._repository);

  Future<ResponseModel> call({required String date}) async {
    return await _repository.getAttendance(date: date);
  }
}

class SaveAttendanceUseCase {
  final AttendanceRepository _repository;

  SaveAttendanceUseCase(this._repository);

  Future<ResponseModel> call({
    required String date,
    required Map<String, dynamic> attendanceData,
  }) async {
    return await _repository.saveAttendance(
      date: date,
      attendanceData: attendanceData,
    );
  }
}
