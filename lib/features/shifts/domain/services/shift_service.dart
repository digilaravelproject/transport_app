import '../../../../core/services/network/response_model.dart';
import '../models/shift_model.dart';
import '../repositories/shift_repository.dart';

abstract class ShiftServiceInterface {
  Future<ResponseModel> createShift({
    required String name,
    required String startTime,
    required String endTime,
    required String type,
    String? date,
    String? notes,
  });
}

class ShiftService implements ShiftServiceInterface {
  final ShiftRepository _shiftRepository;

  ShiftService(this._shiftRepository);

  @override
  Future<ResponseModel> createShift({
    required String name,
    required String startTime,
    required String endTime,
    required String type,
    String? date,
    String? notes,
  }) async {
    return await _shiftRepository.createShift(
      name: name,
      startTime: startTime,
      endTime: endTime,
      type: type,
      date: date,
      notes: notes,
    );
  }
}
