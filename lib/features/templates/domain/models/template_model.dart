class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final String? thumbnail;
  final DateTime lastUpdated;
  final bool isDefault;
  final String? url;

  TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.lastUpdated,
    this.isDefault = false,
   this.thumbnail,
    this.url,
  });
}
