class ReportModel {
  final String id;
  final String reportName;
  final String type; // 'Financial', 'Operational', 'Compliance', 'Performance'
  final String generatedBy;
  final DateTime generatedDate;
  final String format; // 'PDF', 'CSV', 'Excel'
  final String status; // 'Ready', 'Generating', 'Failed'

  ReportModel({
    required this.id,
    required this.reportName,
    required this.type,
    required this.generatedBy,
    required this.generatedDate,
    required this.format,
    required this.status,
  });
}
