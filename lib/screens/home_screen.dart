import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../responsive.dart';
import '../storage_service.dart';
import '../theme/app_theme.dart';
import '../models/expense_model.dart';
import '../models/bill_model.dart';
import '../widgets/dashboard_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _fadeAnims;

  double _totalIncome = 0;
  double _totalExpense = 0;
  int _activeBills = 0;
  int _savingsGoals = 0;
  double _budgetUsedPct = 0;
  int _debtsTracked = 0;
  List<Map<String, dynamic>> _recentItems = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnims = List.generate(
      6,
          (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * 0.1, 0.6 + i * 0.08, curve: Curves.easeOut),
        ),
      ),
    );
    _loadStats();
  }

  void _loadStats() {
    final storage = StorageService.instance;
    final expenses = storage.loadExpenses();
    final bills = storage.loadBills();
    final savings = storage.loadSavings();
    final debts = storage.loadDebts();
    final budget = storage.loadBudget();

    final now = DateTime.now();
    final monthExpenses = expenses
        .where((e) =>
    e.date.month == now.month && e.date.year == now.year)
        .toList();

    double inc = 0, exp = 0;
    for (final e in monthExpenses) {
      if (e.type == TransactionType.income) {
        inc += e.amount;
      } else {
        exp += e.amount;
      }
    }

    final sorted = List<ExpenseModel>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(3).map((e) => {
      'icon': e.type == TransactionType.income ? '💰' : e.category.icon,
      'label': e.title,
      'date': DateFormat('MMM d').format(e.date),
      'amount': e.type == TransactionType.income
          ? '+${_fmt(e.amount)}'
          : '-${_fmt(e.amount)}',
      'isExp': e.type == TransactionType.expense,
    }).toList();

    double budgetPct = 0;
    if (budget.totalBudget > 0) {
      budgetPct =
          (budget.totalSpent / budget.totalBudget * 100).clamp(0, 100);
    }

    setState(() {
      _totalIncome = inc;
      _totalExpense = exp;
      _activeBills = bills.where((b) => !b.isPaid).length;
      _savingsGoals = savings.length;
      _budgetUsedPct = budgetPct;
      _debtsTracked = debts.where((d) => !d.isSettled).length;
      _recentItems = recent;
    });

    _ctrl.forward(from: 0);
  }

  String _fmt(double v) {
    final sym = _currencySymbol(StorageService.instance.loadCurrency());
    if (v >= 1000000) return '$sym${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '$sym${(v / 1000).toStringAsFixed(1)}K';
    return '$sym${v.toStringAsFixed(2)}';
  }

  String _currencySymbol(String code) {
    const map = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'PKR': '₨', 'INR': '₹',
      'AED': 'د.إ', 'SAR': '﷼', 'JPY': '¥', 'CNY': '¥',
      'CAD': 'C\$', 'AUD': 'A\$', 'CHF': 'Fr'
    };
    return map[code] ?? '\$';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(isDark),
              Padding(
                padding: EdgeInsets.all(Responsive.hPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _animated(0, _buildQuickStats(isDark)),
                    SizedBox(height: Responsive.vGap + 4),
                    _animated(
                      1,
                      Text(
                        'Quick Access',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.fontTitle,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.vGap / 2),
                    _animated(2, _buildModuleGrid()),
                    SizedBox(height: Responsive.vGap + 8),
                    _animated(3, _buildTipCard(isDark)),
                    SizedBox(height: Responsive.vGap + 8),
                    _animated(4, _buildRecentActivity(isDark)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animated(int i, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[i],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * 0.1, 0.6 + i * 0.1, curve: Curves.easeOut),
        )),
        child: child,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final balance = _totalIncome - _totalExpense;
    final topPad = Responsive.headerTop(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          Responsive.hPad + 4, topPad, Responsive.hPad + 4, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.gradientPrimary,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Welcome back 👋',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: Responsive.fontCaption + 1,
                  ),
                ),
                Text(
                  'FundNovaX',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: Responsive.fontHero - 4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ]),
            ],
          ),
          SizedBox(height: Responsive.vGap + 4),
          Container(
            padding: EdgeInsets.all(Responsive.hPad),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Responsive.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Month',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: Responsive.fontCaption,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _fmt(balance.abs()),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: Responsive.isXSmall ? 22 : 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: balance >= 0
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFEF5350),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            balance >= 0 ? 'Net Positive' : 'Net Negative',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: Responsive.fontCaption,
                            ),
                          ),
                        ]),
                      ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _miniStat('Income', _fmt(_totalIncome), '↑',
                      const Color(0xFF4CAF50)),
                  const SizedBox(height: 10),
                  _miniStat('Expense', _fmt(_totalExpense), '↓',
                      const Color(0xFFFF6584)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String val, String arrow, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.7),
          fontSize: Responsive.fontCaption,
        ),
      ),
      Row(children: [
        Text(arrow,
            style: TextStyle(color: color, fontSize: Responsive.fontBody)),
        const SizedBox(width: 2),
        Text(
          val,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: Responsive.fontBody + 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
    ]);
  }

  Widget _buildQuickStats(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Responsive.isXSmall ? 8 : 12,
      mainAxisSpacing: Responsive.isXSmall ? 8 : 12,
      childAspectRatio: Responsive.statCardAspect,
      children: [
        SummaryStatCard(
            label: 'Unpaid Bills',
            value: '$_activeBills',
            color: AppTheme.warning,
            icon: '🔔'),
        SummaryStatCard(
            label: 'Savings Goals',
            value: '$_savingsGoals',
            color: AppTheme.secondary,
            icon: '🏦'),
        SummaryStatCard(
            label: 'Budget Used',
            value: '${_budgetUsedPct.toInt()}%',
            color: AppTheme.primary,
            icon: '🎯'),
        SummaryStatCard(
            label: 'Active Debts',
            value: '$_debtsTracked',
            color: AppTheme.accent,
            icon: '🤝'),
      ],
    );
  }

  Widget _buildModuleGrid() {
    final modules = [
      {'icon': '💸', 'label': 'Expenses', 'idx': 1, 'color': AppTheme.accent},
      {'icon': '🎯', 'label': 'Budget', 'idx': 2, 'color': AppTheme.primary},
      {'icon': '🔔', 'label': 'Bills', 'idx': 3, 'color': AppTheme.warning},
      {
        'icon': '🤝',
        'label': 'Debts',
        'idx': 5,
        'color': AppTheme.secondary
      },
      {
        'icon': '🏦',
        'label': 'Savings',
        'idx': 4,
        'color': AppTheme.success
      },
      {'icon': 'ℹ️', 'label': 'About', 'idx': 6, 'color': Colors.purple},
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Responsive.isXSmall ? 8 : 10,
      mainAxisSpacing: Responsive.isXSmall ? 8 : 10,
      childAspectRatio: Responsive.moduleCardAspect,
      children: modules.map((m) {
        final color = m['color'] as Color;
        return GestureDetector(
          onTap: () => widget.onNavigate(m['idx'] as int),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(Responsive.radiusMd),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(m['icon'] as String,
                      style: TextStyle(
                          fontSize: Responsive.isXSmall ? 22 : 26)),
                  SizedBox(height: Responsive.isXSmall ? 4 : 6),
                  Text(
                    m['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.fontCaption,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTipCard(bool isDark) {
    const tips = [
      'Follow the 50/30/20 rule: 50% needs, 30% wants, 20% savings.',
      'Pay yourself first — automate savings before spending.',
      'Track every expense, no matter how small.',
      'Build a 3–6 month emergency fund before investing.',
      'Review subscriptions monthly and cancel unused ones.',
    ];
    final tip = tips[DateTime.now().day % tips.length];
    return Container(
      padding: EdgeInsets.all(Responsive.hPad),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
        borderRadius: BorderRadius.circular(Responsive.radiusLg),
      ),
      child: Row(children: [
        Text('💡',
            style:
            TextStyle(fontSize: Responsive.isXSmall ? 22 : 28)),
        SizedBox(width: Responsive.isXSmall ? 10 : 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Finance Tip',
              style: GoogleFonts.poppins(
                color: AppTheme.secondary,
                fontSize: Responsive.fontCaption,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tip,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.85),
                fontSize: Responsive.fontCaption + 1,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontTitle,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () => widget.onNavigate(1),
            child: Text(
              'See All',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.fontCaption + 1,
                  color: AppTheme.primary),
            ),
          ),
        ]),
        SizedBox(height: Responsive.isXSmall ? 8 : 10),
        if (_recentItems.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(
                vertical: Responsive.isXSmall ? 20 : 28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius:
              BorderRadius.circular(Responsive.radiusMd),
            ),
            child: Center(
              child: Column(children: [
                Text('📊',
                    style: TextStyle(
                        fontSize: Responsive.isXSmall ? 28 : 36)),
                const SizedBox(height: 8),
                Text(
                  'No transactions yet',
                  style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: Responsive.fontBody),
                ),
                Text(
                  'Add your first expense!',
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: Responsive.fontCaption),
                ),
              ]),
            ),
          )
        else
          ..._recentItems.map(
                (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isXSmall ? 12 : 16,
                vertical: Responsive.isXSmall ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius:
                BorderRadius.circular(Responsive.radiusMd),
              ),
              child: Row(children: [
                Container(
                  width: Responsive.isXSmall ? 34 : 40,
                  height: Responsive.isXSmall ? 34 : 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        Responsive.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      item['icon'] as String,
                      style: TextStyle(
                          fontSize: Responsive.isXSmall ? 14 : 18),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.isXSmall ? 8 : 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontBody,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item['date'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontCaption,
                            color: Colors.grey,
                          ),
                        ),
                      ]),
                ),
                Text(
                  item['amount'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.fontBody,
                    fontWeight: FontWeight.w700,
                    color: (item['isExp'] as bool)
                        ? AppTheme.accent
                        : AppTheme.success,
                  ),
                ),
              ]),
            ),
          ),
      ],
    );
  }
}