class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String type; // e.g. 'Invoice', 'Quotation', 'Duty Slip'
  final DateTime lastUpdated;
  final bool isDefault;
  final String? url; // URL for template preview

  TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.lastUpdated,
    this.isDefault = false,
    this.url,
  });
}
