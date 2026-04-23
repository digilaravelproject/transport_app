import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';

abstract class TemplateDefaultRepository {
  Future<ResponseModel> setTemplateAsDefault({
    required int templateId,
    required String referenceType,
  });
}

class TemplateDefaultRepositoryImpl implements TemplateDefaultRepository {
  final ApiClient _apiClient;

  TemplateDefaultRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> setTemplateAsDefault({
    required int templateId,
    required String referenceType,
  }) async {
    try {
      final body = {
        'document_template_id': templateId,
        'reference_type': referenceType,
      };

      print('Setting template as default with body: $body');

      final response = await _apiClient.post(
        '/api/v1/document-templates/submit',
        data: body,
        handleError: false,
        showToaster: false,
      );

      print('Set default response - Success: ${response.isSuccess}, Status: ${response.statusCode}');
      print('Set default response body: ${response.body}');

      if (response.body != null) {
        final responseBody = response.body as Map<String, dynamic>;
        final apiSuccess = responseBody['success'] == true;

        if (apiSuccess) {
          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: responseBody['message'] ?? 'Template set as default successfully',
            body: null,
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to set template as default',
      );
    } catch (e) {
      print('Error setting template as default: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error setting template as default: $e',
      );
    }
  }
}
