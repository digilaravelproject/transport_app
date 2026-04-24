import '../../../../core/services/network/response_model.dart';
import '../repositories/driver_repository.dart';
import '../models/shift_model.dart';

class GetAvailableDriversUseCase {
  final DriverRepository _repository;

  GetAvailableDriversUseCase(this._repository);

  Future<ResponseModel> call({String? search}) async {
    return await _repository.getAvailableDrivers(search: search);
  }
}