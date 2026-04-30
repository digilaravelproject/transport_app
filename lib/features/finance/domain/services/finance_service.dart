import '../../../../core/services/network/response_model.dart';
import '../models/transaction_request_model.dart';
import '../repositories/finance_repository.dart';

class GetFinanceDataUseCase {
  final FinanceRepository _repository;

  GetFinanceDataUseCase(this._repository);

  Future<ResponseModel> call({
    int page = 1,
    int perPage = 10,
    String? type,
    String? category,
  }) async {
    return await _repository.getFinanceData(
      page: page,
      perPage: perPage,
      type: type,
      category: category,
    );
  }
}

class GetTransactionByIdUseCase {
  final FinanceRepository _repository;

  GetTransactionByIdUseCase(this._repository);

  Future<ResponseModel> call(int id) async {
    return await _repository.getTransactionById(id);
  }
}

class AddTransactionUseCase {
  final FinanceRepository _repository;

  AddTransactionUseCase(this._repository);

  Future<ResponseModel> call(TransactionRequestModel request) async {
    return await _repository.addTransaction(request);
  }
}