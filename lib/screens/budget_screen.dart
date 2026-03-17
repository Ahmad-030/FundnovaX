import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';
import '../responsive.dart';
import '../storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_card.dart';
import '../widgets/chart_widget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late BudgetSettings _budget;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final budget = StorageService.instance.loadBudget();
    final expenses = StorageService.instance.loadExpenses();
    final now = DateTime.now();
    final monthlyExp = expenses.where((e) {
      if (budget.period == BudgetPeriod.monthly) {
        return e.date.month == now.month &&
            e.date.year == now.year &&
            e.type == TransactionType.expense;
      } else {
        return e.date.isAfter(
            now.subtract(const Duration(days: 7))) &&
            e.type == TransactionType.expense;
      }
    }).toList();

    for (final cat in budget.categories) {
      cat.spent = monthlyExp
          .where((e) => e.category == cat.category)
          .fold(0, (s, e) => s + e.amount);
    }
    setState(() => _budget = budget);
  }

  Future<void> _save() async =>
      StorageService.instance.saveBudget(_budget);

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
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            _buildHeader(isDark),
            Padding(
              padding: EdgeInsets.all(Responsive.hPad),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodToggle(isDark),
                    SizedBox(height: Responsive.vGap),
                    _budget.totalBudget == 0
                        ? _buildEmptyState(isDark)
                        : _buildContent(isDark),
                    const SizedBox(height: 80),
                  ]),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSetBudgetDialog(context),
        icon: const Icon(Icons.tune),
        label: Text(
          _budget.totalBudget == 0 ? 'Set Budget' : 'Edit Budget',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final topPad = Responsive.headerTop(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          Responsive.hPad, topPad, Responsive.hPad, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: AppTheme.gradientPrimary,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Budget Planner',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: Responsive.fontTitle + 4,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Stay on top of your spending',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: Responsive.fontCaption + 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: EdgeInsets.all(Responsive.isXSmall ? 24 : 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(Responsive.radiusLg),
      ),
      child: Column(children: [
        Text('🎯',
            style: TextStyle(
                fontSize: Responsive.isXSmall ? 36 : 48)),
        const SizedBox(height: 16),
        Text('No Budget Set',
            style: GoogleFonts.poppins(
                fontSize: Responsive.fontTitle,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Tap "Set Budget" to create your first budget plan and start tracking your spending goals.',
          style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: Responsive.fontCaption + 1),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _buildPeriodToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius:
          BorderRadius.circular(Responsive.radiusMd)),
      child: Row(
        children: BudgetPeriod.values.map((p) {
          final sel = p == _budget.period;
          return Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() => _budget = BudgetSettings(
                    totalBudget: _budget.totalBudget,
                    period: p,
                    categories: _budget.categories));
                await _save();
                _load();
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: Responsive.isXSmall ? 8 : 10),
                decoration: BoxDecoration(
                    color: sel
                        ? AppTheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                        Responsive.radiusSm)),
                child: Center(
                  child: Text(
                    p == BudgetPeriod.weekly
                        ? 'Weekly'
                        : 'Monthly',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.fontBody,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final isOver = _budget.totalSpent > _budget.totalBudget;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildOverallCard(isDark, isOver),
      SizedBox(height: Responsive.vGap + 4),
      if (_budget.categories.isNotEmpty) ...[
        _buildComparisonChart(isDark),
        SizedBox(height: Responsive.vGap + 4),
        Text('Category Budgets',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontTitle,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            )),
        SizedBox(height: Responsive.isXSmall ? 8 : 12),
        ..._budget.categories
            .map((cat) => _buildCategoryCard(cat, isDark)),
      ],
    ]);
  }

  Widget _buildOverallCard(bool isDark, bool isOver) {
    return Container(
      padding: EdgeInsets.all(Responsive.isXSmall ? 14 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: AppTheme.gradientDark),
        borderRadius:
        BorderRadius.circular(Responsive.radiusLg),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          AnimatedProgressRing(
            progress: _budget.usagePercent,
            color: isOver ? AppTheme.error : AppTheme.secondary,
            size: Responsive.isXSmall ? 80 : 100,
            centerText:
            '\$${_budget.totalSpent.toStringAsFixed(0)}',
            bottomLabel: 'Spent',
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _budgetStat('Total Budget',
                '\$${_budget.totalBudget.toStringAsFixed(0)}',
                Colors.white),
            const SizedBox(height: 12),
            _budgetStat(
                'Spent',
                '\$${_budget.totalSpent.toStringAsFixed(0)}',
                isOver ? AppTheme.error : AppTheme.success),
            const SizedBox(height: 12),
            _budgetStat(
                'Remaining',
                '\$${_budget.totalRemaining.toStringAsFixed(0)}',
                AppTheme.secondary),
          ]),
        ]),
        if (isOver) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.error.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppTheme.error, size: 16),
              const SizedBox(width: 8),
              Text(
                'You\'ve exceeded your budget!',
                style: GoogleFonts.poppins(
                    color: AppTheme.error,
                    fontSize: Responsive.fontCaption + 1,
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _budgetStat(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: Responsive.fontCaption)),
      Text(value,
          style: GoogleFonts.poppins(
              color: color,
              fontSize: Responsive.isXSmall ? 13 : 16,
              fontWeight: FontWeight.w800)),
    ]);
  }

  Widget _buildComparisonChart(bool isDark) {
    final data = <String, List<double>>{};
    for (final c in _budget.categories) {
      final key = c.category.label
          .substring(0, c.category.label.length > 5 ? 5 : c.category.label.length);
      data[key] = [c.limit, c.spent];
    }
    return Container(
      padding: EdgeInsets.all(Responsive.isXSmall ? 12 : 16),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius:
          BorderRadius.circular(Responsive.radiusLg)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Budget vs Spending',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.fontBody + 1,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          _legendDot('Budget', AppTheme.primary.withOpacity(0.6)),
          const SizedBox(width: 10),
          _legendDot('Spent', AppTheme.success),
        ]),
        SizedBox(height: Responsive.isXSmall ? 10 : 14),
        SizedBox(
            height: Responsive.isXSmall ? 110 : 140,
            child: BudgetComparisonChart(data: data)),
      ]),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: Responsive.fontCaption, color: Colors.grey)),
    ]);
  }

  Widget _buildCategoryCard(BudgetCategory cat, bool isDark) {
    final color = _categoryColor(cat.category);
    final isOver = cat.isOverBudget;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(Responsive.isXSmall ? 10 : 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(Responsive.radiusMd),
        border: isOver
            ? Border.all(color: AppTheme.error.withOpacity(0.3))
            : null,
      ),
      child: Column(children: [
        Row(children: [
          Text(cat.category.icon,
              style: TextStyle(
                  fontSize: Responsive.isXSmall ? 16 : 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(cat.category.label,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.fontBody)),
          ),
          if (isOver)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('Over!',
                  style: GoogleFonts.poppins(
                      color: AppTheme.error,
                      fontSize: Responsive.fontCaption,
                      fontWeight: FontWeight.w700)),
            ),
          const SizedBox(width: 8),
          FittedBox(
            child: Text(
              '\$${cat.spent.toStringAsFixed(0)} / \$${cat.limit.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.fontCaption + 1,
                  fontWeight: FontWeight.w600,
                  color: isOver ? AppTheme.error : color),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: cat.usagePercent,
            minHeight: 7,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? AppTheme.error : color),
          ),
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(cat.usagePercent * 100).toInt()}% used',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.fontCaption,
                  color: Colors.grey)),
          Text('\$${cat.remaining.toStringAsFixed(0)} left',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.fontCaption,
                  color: isOver ? AppTheme.error : AppTheme.success,
                  fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  void _showSetBudgetDialog(BuildContext context) {
    Responsive.init(context);
    final totalCtrl = TextEditingController(
        text: _budget.totalBudget > 0
            ? _budget.totalBudget.toStringAsFixed(0)
            : '');
    final catLimits = <ExpenseCategory, TextEditingController>{};
    for (final c in ExpenseCategory.values) {
      final existing = _budget.categories.firstWhere(
              (x) => x.category == c,
          orElse: () =>
              BudgetCategory(id: '', category: c, limit: 0));
      catLimits[c] = TextEditingController(
          text: existing.limit > 0
              ? existing.limit.toStringAsFixed(0)
              : '');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, _) {
          Responsive.init(ctx);
          final isDark =
              Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: Responsive.hPad,
              right: Responsive.hPad,
              top: Responsive.isXSmall ? 16 : 20,
            ),
            decoration: BoxDecoration(
              color:
              isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    SizedBox(height: Responsive.isXSmall ? 12 : 16),
                    Text('Set Budget',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.fontTitle,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: Responsive.isXSmall ? 10 : 14),
                    TextField(
                      controller: totalCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: TextStyle(fontSize: Responsive.fontBody),
                      decoration: const InputDecoration(
                          labelText: 'Total Budget',
                          prefixText: '\$ ',
                          prefixIcon: Icon(
                              Icons.account_balance_wallet_outlined)),
                    ),
                    SizedBox(height: Responsive.vGap),
                    Text('Category Limits (optional)',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.fontBody + 1,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                    SizedBox(height: Responsive.isXSmall ? 8 : 10),
                    ...ExpenseCategory.values.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: catLimits[c],
                        keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                        style: TextStyle(
                            fontSize: Responsive.fontBody),
                        decoration: InputDecoration(
                          labelText: '${c.icon} ${c.label} limit',
                          prefixText: '\$ ',
                        ),
                      ),
                    )),
                    SizedBox(height: Responsive.isXSmall ? 12 : 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical:
                                Responsive.isXSmall ? 12 : 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Responsive.radiusMd))),
                        onPressed: () async {
                          final total =
                          double.tryParse(totalCtrl.text);
                          if (total == null || total <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Enter a valid total budget')));
                            return;
                          }
                          final cats = <BudgetCategory>[];
                          for (final c in ExpenseCategory.values) {
                            final limit =
                                double.tryParse(catLimits[c]!.text) ??
                                    0;
                            if (limit > 0) {
                              final existing = _budget.categories
                                  .firstWhere((x) => x.category == c,
                                  orElse: () => BudgetCategory(
                                      id: const Uuid().v4(),
                                      category: c,
                                      limit: 0));
                              cats.add(
                                  existing.copyWith(limit: limit));
                            }
                          }
                          setState(() {
                            _budget = BudgetSettings(
                                totalBudget: total,
                                period: _budget.period,
                                categories: cats);
                          });
                          await _save();
                          _load();
                          if (mounted) Navigator.pop(context);
                        },
                        child: Text('Save Budget',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: Responsive.fontBody)),
                      ),
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }
}