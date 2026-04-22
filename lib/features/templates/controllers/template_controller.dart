import 'package:get/get.dart';
import '../domain/models/template_model.dart';

class TemplateController extends GetxController {
  final RxList<TemplateModel> templates = <TemplateModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  // Available filter types
  final List<String> filterTypes = ['All', 'Invoice', 'Quotation', 'Duty Slip'];

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
        url: 'https://canva.link/3n4pcyyavqsqh35', // Demo URL
      ),
      TemplateModel(
        id: '2',
        name: 'Corporate Quotation',
        description: 'Detailed quotation for corporate contracts',
        type: 'Quotation',
        lastUpdated: DateTime.now().subtract(const Duration(days: 12)),
        isDefault: true,
        url: 'https://canva.link/3n4pcyyavqsqh35', // Demo URL
      ),
      TemplateModel(
        id: '3',
        name: 'Driver Duty Slip',
        description: 'Basic duty slip for drivers to carry',
        type: 'Duty Slip',
        lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
        isDefault: true,
        url: 'https://canva.link/3n4pcyyavqsqh35', // Demo URL
      ),
      TemplateModel(
        id: '4',
        name: 'Wedding Package Invoice',
        description: 'Special invoice with wedding event branding',
        type: 'Invoice',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        url: 'https://canva.link/3n4pcyyavqsqh35', // Demo URL
      ),
      TemplateModel(
        id: '5',
        name: 'Express Quotation',
        description: 'Quick quotation template for urgent requests',
        type: 'Quotation',
        lastUpdated: DateTime.now().subtract(const Duration(days: 8)),
        url: 'https://canva.link/3n4pcyyavqsqh35', // Demo URL
      ),
      TemplateModel(
        id: '6',
        name: 'Night Duty Slip',
        description: 'Special duty slip for night shifts',
        type: 'Duty Slip',
        lastUpdated: DateTime.now().subtract(const Duration(days: 15)),
        url: 'https://canva.link/3n4pcyyavqsqh35', // Demo URL
      ),
    ];
  }

  List<TemplateModel> get filteredTemplates {
    List<TemplateModel> filtered = templates;

    // Apply type filter
    if (selectedFilter.value != 'All') {
      filtered = filtered.where((template) => 
        template.type == selectedFilter.value
      ).toList();
    }

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
