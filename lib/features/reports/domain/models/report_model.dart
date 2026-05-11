class ReportModel {
  final String id;
  final String reportName;
  final String type; // 'Financial', 'Operational', 'Compliance', 'Performance'
  final String? generatedBy;
  final DateTime generatedDate;
  final String format; // 'PDF', 'CSV', 'Excel'
  final String status; // 'Ready', 'Generating', 'Failed'
  final String? filePath;

  ReportModel({
    required this.id,
    required this.reportName,
    required this.type,
    this.generatedBy,
    required this.generatedDate,
    required this.format,
    required this.status,
    this.filePath,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'].toString(),
      reportName: json['name'] ?? '',
      type: json['type'] ?? '',
      generatedBy: json['generated_by']?.toString(),
      generatedDate: DateTime.parse(json['created_at']),
      format: json['format']?.toString().toUpperCase() ?? 'PDF',
      status: json['status'] ?? 'Ready',
      filePath: json['file_path'],
    );
  }
}
