import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/template_model.dart';

abstract class TemplateRepository {
  Future<ResponseModel> getTemplates({
    String? category,
    String? search,
  });
}

class TemplateRepositoryImpl implements TemplateRepository {
  final ApiClient _apiClient;

  TemplateRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> getTemplates({
    String? category,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category.toLowerCase();
      }
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        AppConstants.documentTemplatesEndpoint,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      print('Raw API Response Body Type: ${response.body.runtimeType}');
      print('Raw API Response Body: ${response.body}');

      if (response.isSuccess && response.body != null) {
        try {
          List<dynamic> data = [];
          
          // Handle different response formats
          if (response.body is Map<String, dynamic>) {
            final body = response.body as Map<String, dynamic>;
            data = body['data'] as List<dynamic>? ?? [];
          } else if (response.body is List<dynamic>) {
            data = response.body as List<dynamic>;
          }
          
          print('Extracted data list length: ${data.length}');
          
          if (data.isNotEmpty) {
            final templates = data
                .map((item) {
                  try {
                    print('Processing template item: $item');
                    return TemplateModel(
                      id: item['id']?.toString() ?? '',
                      name: item['name'] ?? '',
                      description: item['description'] ?? '',
                      type: item['type'] ?? '',
                      lastUpdated: item['lastUpdated'] != null
                          ? DateTime.parse(item['lastUpdated'].toString())
                          : DateTime.now(),
                      isDefault: item['is_default'] ?? false,
                      url: item['url'],
                      thumbnail: item['thumbnail'],
                    );
                  } catch (e) {
                    print('Error parsing template item: $e, item: $item');
                    rethrow;
                  }
                })
                .toList();
            
            print('Successfully created ${templates.length} templates');
            
            return ResponseModel(
              isSuccess: true,
              statusCode: response.statusCode,
              message: response.message,
              body: templates,
            );
          } else {
            // Empty data list
            print('No templates in response');
            return ResponseModel(
              isSuccess: true,
              statusCode: response.statusCode,
              message: 'No templates found',
              body: <TemplateModel>[],
            );
          }
        } catch (e) {
          print('Error processing template response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing templates: $e',
            body: <TemplateModel>[],
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to fetch templates',
        body: <TemplateModel>[],
      );
    } catch (e) {
      print('Error fetching templates: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching templates: $e',
        body: <TemplateModel>[],
      );
    }
  }
}
