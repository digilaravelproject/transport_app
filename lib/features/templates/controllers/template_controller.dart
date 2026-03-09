import 'package:get/get.dart';
import '../domain/models/template_model.dart';

class TemplateController extends GetxController {
  final RxList<TemplateModel> templates = <TemplateModel>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    templates.value = [
      TemplateModel(
        id: '1',
        name: 'Standard Invoice',
        description: 'Default invoice template for general trips',
        type: 'Invoice',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        isDefault: true,
      ),
      TemplateModel(
        id: '2',
        name: 'Corporate Quotation',
        description: 'Detailed quotation for corporate contracts',
        type: 'Quotation',
        lastUpdated: DateTime.now().subtract(const Duration(days: 12)),
        isDefault: true,
      ),
      TemplateModel(
        id: '3',
        name: 'Driver Duty Slip',
        description: 'Basic duty slip for drivers to carry',
        type: 'Duty Slip',
        lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
        isDefault: true,
      ),
      TemplateModel(
        id: '4',
        name: 'Wedding Package Invoice',
        description: 'Special invoice with wedding event branding',
        type: 'Invoice',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<TemplateModel> get filteredTemplates {
    if (searchQuery.value.isEmpty) {
      return templates;
    }
    return templates.where((template) => 
      template.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      template.type.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
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
