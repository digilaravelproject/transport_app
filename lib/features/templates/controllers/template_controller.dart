import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../domain/models/template_model.dart';
import '../domain/repositories/template_repository.dart';
import '../domain/repositories/template_default_repository.dart';

class TemplateController extends GetxController {
  final RxList<TemplateModel> templates = <TemplateModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;

  // Available filter types
  final List<String> filterTypes = ['All', 'Invoice', 'Quotation', 'Duty Slip'];

  late TemplateRepository _templateRepository;
  late TemplateDefaultRepository _templateDefaultRepository;

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
    _loadTemplates();
  }

  void _initializeRepository() {
    _templateRepository = TemplateRepositoryImpl(ApiClient());
    _templateDefaultRepository = TemplateDefaultRepositoryImpl(ApiClient());
  }

  Future<void> _loadTemplates({String? category, String? search}) async {
    try {
      isLoading.value = true;
      
      final response = await _templateRepository.getTemplates(
        category: category,
        search: search,
      );

      print('Template Response - Success: ${response.isSuccess}, Body Type: ${response.body.runtimeType}, Body: ${response.body}');

      if (response.isSuccess && response.body != null) {
        try {
          // Response body should be a List<TemplateModel>
          if (response.body is List) {
            final templateList = response.body as List;
            print('Template List Length: ${templateList.length}');
            
            if (templateList.isNotEmpty) {
              print('First item type: ${templateList.first.runtimeType}');
            }
            
            templates.value = templateList.cast<TemplateModel>();
            print('Templates set successfully. Count: ${templates.length}');
          } else {
            print('Response body is not a list: ${response.body.runtimeType}');
            CustomSnackbar.showError('Invalid response format');
          }
        } catch (e) {
          print('Error casting templates: $e');
          CustomSnackbar.showError('Error processing templates: $e');
        }
      } else {
        print('Response not successful or body is null');
        CustomSnackbar.showError(response.message ?? 'Failed to load templates');
      }
    } catch (e) {
      print('Error loading templates: $e');
      CustomSnackbar.showError('Error loading templates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<TemplateModel> get filteredTemplates {
    List<TemplateModel> filtered = templates;

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((template) => 
        template.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        template.type.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        template.description.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _loadTemplates(category: filter);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _loadTemplates(
      category: selectedFilter.value != 'All' ? selectedFilter.value : null,
      search: query.isNotEmpty ? query : null,
    );
  }

  Future<void> setTemplateAsDefault(int templateId) async {
    try {
      isLoading.value = true;

      final response = await _templateDefaultRepository.setTemplateAsDefault(
        templateId: templateId,
        referenceType: 'Trip',
      );

      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? 'Template set as default successfully');
        // Refresh the template list
        await _loadTemplates();
      } else {
        CustomSnackbar.showError(response.message ?? 'Failed to set template as default');
      }
    } catch (e) {
      print('Error setting template as default: $e');
      CustomSnackbar.showError('Error setting template as default: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addTemplate(TemplateModel template) {
    templates.add(template);
  }

  void updateTemplate(TemplateModel template) {
    int index = templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      templates[index] = template;
    }
  }

  void deleteTemplate(String id) {
    templates.removeWhere((t) => t.id == id);
  }
}
