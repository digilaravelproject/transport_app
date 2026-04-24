import '../../../../core/services/network/response_model.dart';
import '../repositories/vehicle_repository.dart';

class GetVehiclesUseCase {
  final VehicleRepository _repository;

  GetVehiclesUseCase(this._repository);

  Future<ResponseModel> call({String? search}) async {
    return await _repository.getVehicles(search: search);
  }
}

class AssignVehicleToRouteUseCase {
  final VehicleRepository _repository;

  AssignVehicleToRouteUseCase(this._repository);

  Future<ResponseModel> call({
    required int routeId,
    required int vehicleId,
  }) async {
    return await _repository.assignVehicleToRoute(
      routeId: routeId,
      vehicleId: vehicleId,
    );
  }
}