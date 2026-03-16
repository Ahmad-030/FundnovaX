enum ExpenseCategory { food, transport, shopping, bills, other }
enum TransactionType { income, expense }

extension ExpenseCategoryExt on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food: return 'Food';
      case ExpenseCategory.transport: return 'Transport';
      case ExpenseCategory.shopping: return 'Shopping';
      case ExpenseCategory.bills: return 'Bills';
      case ExpenseCategory.other: return 'Other';
    }
  }
  String get icon {
    switch (this) {
      case ExpenseCategory.food: return '🍔';
      case ExpenseCategory.transport: return '🚗';
      case ExpenseCategory.shopping: return '🛍️';
      case ExpenseCategory.bills: return '📄';
      case ExpenseCategory.other: return '💡';
    }
  }
}

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final TransactionType type;
  final DateTime date;
  final bool isRecurring;
  final String? note;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.isRecurring = false,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category.index,
    'type': type.index,
    'date': date.toIso8601String(),
    'isRecurring': isRecurring,
    'note': note,
  };

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: ExpenseCategory.values[json['category'] as int],
    type: TransactionType.values[json['type'] as int],
    date: DateTime.parse(json['date'] as String),
    isRecurring: json['isRecurring'] as bool? ?? false,
    note: json['note'] as String?,
  );

  ExpenseModel copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    TransactionType? type,
    DateTime? date,
    bool? isRecurring,
    String? note,
  }) => ExpenseModel(
    id: id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    type: type ?? this.type,
    date: date ?? this.date,
    isRecurring: isRecurring ?? this.isRecurring,
    note: note ?? this.note,
  );
}