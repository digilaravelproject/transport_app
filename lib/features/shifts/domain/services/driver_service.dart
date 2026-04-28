import '../../../../core/services/network/response_model.dart';
import '../repositories/driver_repository.dart';
import '../models/shift_model.dart';

class GetAvailableDriversUseCase {
  final DriverRepository _repository;

  GetAvailableDriversUseCase(this._repository);

  Future<ResponseModel> call({
    required int shiftId,
    String? search,
  }) async {
    return await _repository.getAvailableDrivers(
      shiftId: shiftId,
      search: search,
    );
  }
}

class AssignDriversToShiftUseCase {
  final DriverRepository _repository;

  AssignDriversToShiftUseCase(this._repository);

  Future<ResponseModel> call({
    required int shiftId,
    required List<int> driverIds,
  }) async {
    return await _repository.assignDriversToShift(
      shiftId: shiftId,
      driverIds: driverIds,
    );
  }
}

class RemoveDriverFromShiftUseCase {
  final DriverRepository _repository;

  RemoveDriverFromShiftUseCase(this._repository);

  Future<ResponseModel> call({
    required int shiftId,
    required int driverId,
  }) async {
    return await _repository.removeDriverFromShift(
      shiftId: shiftId,
      driverId: driverId,
    );
  }
}