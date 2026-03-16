import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_card.dart';
import '../widgets/chart_widget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  BudgetPeriod _period = BudgetPeriod.monthly;
  double _totalBudget = 2000;

  final List<BudgetCategory> _categories = [
    BudgetCategory(id: '1', category: ExpenseCategory.food, limit: 400, spent: 268),
    BudgetCategory(id: '2', category: ExpenseCategory.transport, limit: 200, spent: 88),
    BudgetCategory(id: '3', category: ExpenseCategory.shopping, limit: 300, spent: 345),
    BudgetCategory(id: '4', category: ExpenseCategory.bills, limit: 600, spent: 510),
    BudgetCategory(id: '5', category: ExpenseCategory.other, limit: 200, spent: 95),
  ];

  double get _totalSpent => _categories.fold(0, (s, c) => s + c.spent);
  double get _totalRemaining => (_totalBudget - _totalSpent).clamp(0, double.infinity);
  double get _overallProgress => _totalBudget > 0 ? (_totalSpent / _totalBudget).clamp(0, 1) : 0;

  Color _categoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food: return AppTheme.food;
      case ExpenseCategory.transport: return AppTheme.transport;
      case ExpenseCategory.shopping: return AppTheme.shopping;
      case ExpenseCategory.bills: return AppTheme.bills;
      case ExpenseCategory.other: return AppTheme.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDark),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodToggle(isDark),
                  const SizedBox(height: 16),
                  _buildOverallCard(isDark),
                  const SizedBox(height: 20),
                  _buildComparisonChart(isDark),
                  const SizedBox(height: 20),
                  Text('Category Budgets', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 12),
                  ..._categories.map((cat) => _buildCategoryCard(cat, isDark)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSetBudgetDialog(context),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.tune),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppTheme.gradientPrimary, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎯 Budget Planner', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          Text('Stay on top of your spending', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: BudgetPeriod.values.map((p) {
          final sel = p == _period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _period = p),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(p == BudgetPeriod.weekly ? 'Weekly' : 'Monthly',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.grey))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverallCard(bool isDark) {
    final isOver = _totalSpent > _totalBudget;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppTheme.gradientDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedProgressRing(
                progress: _overallProgress,
                color: isOver ? AppTheme.error : AppTheme.secondary,
                size: 100,
                centerText: '\$${_totalSpent.toStringAsFixed(0)}',
                bottomLabel: 'Spent',
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _budgetStat('Total Budget', '\$${_totalBudget.toStringAsFixed(0)}', Colors.white),
                  const SizedBox(height: 12),
                  _budgetStat('Spent', '\$${_totalSpent.toStringAsFixed(0)}', isOver ? AppTheme.error : AppTheme.success),
                  const SizedBox(height: 12),
                  _budgetStat('Remaining', '\$${_totalRemaining.toStringAsFixed(0)}', AppTheme.secondary),
                ],
              ),
            ],
          ),
          if (isOver) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.error.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 16),
                const SizedBox(width: 8),
                Text('You\'ve exceeded your budget!', style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _budgetStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
        Text(value, style: GoogleFonts.poppins(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildComparisonChart(bool isDark) {
    final data = <String, List<double>>{};
    for (final c in _categories) {
      data[c.category.label.substring(0, c.category.label.length > 5 ? 5 : c.category.label.length)] = [c.limit, c.spent];
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Budget vs Spending', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              _legendDot('Budget', AppTheme.primary.withOpacity(0.6)),
              const SizedBox(width: 10),
              _legendDot('Spent', AppTheme.success),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(height: 140, child: BudgetComparisonChart(data: data)),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
    ]);
  }

  Widget _buildCategoryCard(BudgetCategory cat, bool isDark) {
    final color = _categoryColor(cat.category);
    final isOver = cat.isOverBudget;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOver ? Border.all(color: AppTheme.error.withOpacity(0.3)) : null,
      ),
      child: Column(
        children: [
          Row(children: [
            Text(cat.category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Text(cat.category.label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13))),
            if (isOver) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text('Over!', style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text('\$${cat.spent.toStringAsFixed(0)} / \$${cat.limit.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isOver ? AppTheme.error : color)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: cat.usagePercent,
              minHeight: 7,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(isOver ? AppTheme.error : color),
            ),
          ),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${(cat.usagePercent * 100).toInt()}% used', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
            Text('\$${cat.remaining.toStringAsFixed(0)} left', style: GoogleFonts.poppins(fontSize: 10, color: isOver ? AppTheme.error : AppTheme.success, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _totalBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Budget', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '\$ ', labelText: 'Total Budget'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              setState(() => _totalBudget = double.tryParse(ctrl.text) ?? _totalBudget);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
