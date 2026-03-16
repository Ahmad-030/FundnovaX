import 'expense_model.dart';

enum BudgetPeriod { weekly, monthly }

class BudgetCategory {
  final String id;
  final ExpenseCategory category;
  final double limit;
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

  BudgetCategory copyWith({double? limit, double? spent}) {
    return BudgetCategory(
      id: id,
      category: category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }
}

class BudgetModel {
  final String id;
  final double totalBudget;
  final BudgetPeriod period;
  final List<BudgetCategory> categories;
  final DateTime startDate;

  BudgetModel({
    required this.id,
    required this.totalBudget,
    required this.period,
    required this.categories,
    required this.startDate,
  });

  double get totalSpent => categories.fold(0, (s, c) => s + c.spent);
  double get totalRemaining => (totalBudget - totalSpent).clamp(0, double.infinity);
  double get usagePercent => totalBudget > 0 ? (totalSpent / totalBudget).clamp(0, 1) : 0;
}
