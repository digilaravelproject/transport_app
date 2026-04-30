class TransactionModel {
  final int id;
  final String entryType; // 'income' or 'expense'
  final String status;
  final String paymentMode;
  final String category;
  final double amount;
  final String description;
  final DateTime entryDate;
  final String? referenceNumber;
  final String? receiptPath;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CreatorModel? creator;

  TransactionModel({
    required this.id,
    required this.entryType,
    required this.status,
    required this.paymentMode,
    required this.category,
    required this.amount,
    required this.description,
    required this.entryDate,
    this.referenceNumber,
    this.receiptPath,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      entryType: json['entry_type'] ?? '',
      status: json['status'] ?? '',
      paymentMode: json['payment_mode'] ?? '',
      category: json['category'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      description: json['description'] ?? '',
      entryDate: DateTime.parse(json['entry_date']),
      referenceNumber: json['reference_number'],
      receiptPath: json['receipt_path'],
      createdBy: json['created_by'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      creator: json['creator'] != null ? CreatorModel.fromJson(json['creator']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entry_type': entryType,
      'status': status,
      'payment_mode': paymentMode,
      'category': category,
      'amount': amount.toString(),
      'description': description,
      'entry_date': entryDate.toIso8601String(),
      'reference_number': referenceNumber,
      'receipt_path': receiptPath,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'creator': creator?.toJson(),
    };
  }

  // Helper getters for UI
  String get type => entryType; // For backward compatibility
  String get paymentMethod => _formatPaymentMode(paymentMode);
  DateTime get date => entryDate; // For backward compatibility
  String? get referenceNo => referenceNumber; // For backward compatibility

  String _formatPaymentMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'upi':
        return 'UPI';
      case 'cash':
        return 'Cash';
      case 'cheque':
        return 'Cheque';
      default:
        return mode.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
        ).join(' ');
    }
  }

  String get displayCategory {
    return category.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
    ).join(' ');
  }
}

class FinanceSummary {
  final double totalIn;
  final double totalOut;
  final double currentBalance;

  FinanceSummary({
    required this.totalIn,
    required this.totalOut,
    required this.currentBalance,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalIn: double.tryParse(json['total_in']?.toString() ?? '0') ?? 0.0,
      totalOut: double.tryParse(json['total_out']?.toString() ?? '0') ?? 0.0,
      currentBalance: double.tryParse(json['current_balance']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class FinanceResponse {
  final FinanceSummary summary;
  final List<TransactionModel> transactions;
  final PaginationMeta meta;

  FinanceResponse({
    required this.summary,
    required this.transactions,
    required this.meta,
  });

  factory FinanceResponse.fromJson(Map<String, dynamic> json) {
    return FinanceResponse(
      summary: FinanceSummary.fromJson(json['summary'] ?? {}),
      transactions: (json['data']['data'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e))
              .toList() ??
          [],
      meta: PaginationMeta.fromJson(json['data'] ?? {}),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
}

class CreatorModel {
  final int id;
  final String name;
  final String email;
  final String role;

  CreatorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
