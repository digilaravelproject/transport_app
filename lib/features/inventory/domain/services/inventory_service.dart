import '../../../../core/services/network/response_model.dart';
import '../models/inventory_item_request_model.dart';
import '../repositories/inventory_repository.dart';

class AddInventoryItemUseCase {
  final InventoryRepository _repository;

  AddInventoryItemUseCase(this._repository);

  Future<ResponseModel> call(InventoryItemRequestModel request) async {
    return await _repository.addInventoryItem(request);
  }
}

class GetInventoryDataUseCase {
  final InventoryRepository _repository;

  GetInventoryDataUseCase(this._repository);

  Future<ResponseModel> call({
    int page = 1,
    int perPage = 10,
    String? category,
  }) async {
    return await _repository.getInventoryData(
      page: page,
      perPage: perPage,
      category: category,
    );
  }
}

class GetInventoryDetailsUseCase {
  final InventoryRepository _repository;

  GetInventoryDetailsUseCase(this._repository);

  Future<ResponseModel> call(int id) async {
    return await _repository.getInventoryDetails(id);
  }
}

class GetInventoryStocksUseCase {
  final InventoryRepository _repository;

  GetInventoryStocksUseCase(this._repository);

  Future<ResponseModel> call(int id, {int page = 1, int perPage = 20}) async {
    return await _repository.getInventoryStocks(id, page: page, perPage: perPage);
  }
}

class UpdateInventoryItemUseCase {
  final InventoryRepository _repository;

  UpdateInventoryItemUseCase(this._repository);

  Future<ResponseModel> call(int id, InventoryItemRequestModel request) async {
    return await _repository.updateInventoryItem(id, request);
  }
}

class DeleteInventoryItemUseCase {
  final InventoryRepository _repository;

  DeleteInventoryItemUseCase(this._repository);

  Future<ResponseModel> call(int id) async {
    return await _repository.deleteInventoryItem(id);
  }
}

class StockInUseCase {
  final InventoryRepository _repository;

  StockInUseCase(this._repository);

  Future<ResponseModel> call(int id, Map<String, dynamic> data) async {
    return await _repository.stockIn(id, data);
  }
}

class StockOutUseCase {
  final InventoryRepository _repository;

  StockOutUseCase(this._repository);

  Future<ResponseModel> call(int id, Map<String, dynamic> data) async {
    return await _repository.stockOut(id, data);
  }
}
