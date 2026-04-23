import '../../../../core/services/network/response_model.dart';
import '../models/template_model.dart';
import '../repositories/template_repository.dart';

abstract class TemplateServiceInterface {
  Future<ResponseModel> getTemplates({
    String? category,
    String? search,
  });
}

class TemplateService implements TemplateServiceInterface {
  final TemplateRepository _templateRepository;

  TemplateService(this._templateRepository);

  @override
  Future<ResponseModel> getTemplates({
    String? category,
    String? search,
  }) async {
    return await _templateRepository.getTemplates(
      category: category,
      search: search,
    );
  }
}
