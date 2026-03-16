import 'expense_model.dart';

enum BudgetPeriod { weekly, monthly }

class BudgetCategory {
  final String id;
  final ExpenseCategory category;
  double limit;
  double spent;

  BudgetCategory({
    required this.id,
    required this.category,
    required this.limit,
    this.spent = 0,
  });

  double get remaining => (limit - spent).clamp(0, double.infinity);
  double get usagePercent => limit > 0 ? (spent / limit).clamp(0, 1) : 0;
  bool get isOverBudget => spent > limit;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.index,
    'limit': limit,
    'spent': spent,
  };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
    id: json['id'] as String,
    category: ExpenseCategory.values[json['category'] as int],
    limit: (json['limit'] as num).toDouble(),
    spent: (json['spent'] as num? ?? 0).toDouble(),
  );

  BudgetCategory copyWith({double? limit, double? spent}) => BudgetCategory(
    id: id,
    category: category,
    limit: limit ?? this.limit,
    spent: spent ?? this.spent,
  );
}

class BudgetSettings {
  final double totalBudget;
  final BudgetPeriod period;
  final List<BudgetCategory> categories;

  BudgetSettings({
    required this.totalBudget,
    required this.period,
    required this.categories,
  });

  double get totalSpent => categories.fold(0, (s, c) => s + c.spent);
  double get totalRemaining => (totalBudget - totalSpent).clamp(0, double.infinity);
  double get usagePercent => totalBudget > 0 ? (totalSpent / totalBudget).clamp(0, 1) : 0;

  Map<String, dynamic> toJson() => {
    'totalBudget': totalBudget,
    'period': period.index,
    'categories': categories.map((c) => c.toJson()).toList(),
  };

  factory BudgetSettings.fromJson(Map<String, dynamic> json) => BudgetSettings(
    totalBudget: (json['totalBudget'] as num).toDouble(),
    period: BudgetPeriod.values[json['period'] as int],
    categories: (json['categories'] as List)
        .map((c) => BudgetCategory.fromJson(c as Map<String, dynamic>))
        .toList(),
  );

  static BudgetSettings defaultSettings() {
    return BudgetSettings(
      totalBudget: 0,
      period: BudgetPeriod.monthly,
      categories: [],
    );
  }
}