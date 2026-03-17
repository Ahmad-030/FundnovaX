import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chart_widget.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'Monthly';
  final List<String> _filters = ['Daily', 'Weekly', 'Monthly', 'All'];
  List<ExpenseModel> _expenses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  void _load() {
    setState(() => _expenses = StorageService.instance.loadExpenses());
  }

  Future<void> _save() async {
    await StorageService.instance.saveExpenses(_expenses);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ExpenseModel> get _filtered {
    final now = DateTime.now();
    return _expenses.where((e) {
      if (_filter == 'Daily')
        return e.date.day == now.day &&
            e.date.month == now.month &&
            e.date.year == now.year;
      if (_filter == 'Weekly')
        return e.date.isAfter(now.subtract(const Duration(days: 7)));
      if (_filter == 'Monthly')
        return e.date.month == now.month && e.date.year == now.year;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get _totalIncome => _filtered
      .where((e) => e.type == TransactionType.income)
      .fold(0, (s, e) => s + e.amount);
  double get _totalExpense => _filtered
      .where((e) => e.type == TransactionType.expense)
      .fold(0, (s, e) => s + e.amount);

  Map<String, double> get _categoryData {
    final map = <String, double>{};
    for (final e
    in _filtered.where((e) => e.type == TransactionType.expense)) {
      map[e.category.label] = (map[e.category.label] ?? 0) + e.amount;
    }
    return map;
  }

  Map<String, double> get _monthlyData {
    final map = <String, double>{};
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    for (final e
    in _expenses.where((e) => e.type == TransactionType.expense)) {
      final key = months[e.date.month - 1];
      map[key] = (map[key] ?? 0) + e.amount;
    }
    return map;
  }

  Color _catColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return AppTheme.food;
      case ExpenseCategory.transport:
        return AppTheme.transport;
      case ExpenseCategory.shopping:
        return AppTheme.shopping;
      case ExpenseCategory.bills:
        return AppTheme.bills;
      case ExpenseCategory.other:
        return AppTheme.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) =>
        [SliverToBoxAdapter(child: _buildHeader(isDark))],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChips(isDark),
              const SizedBox(height: 16),
              _buildSummaryCards(isDark),
              const SizedBox(height: 20),
              _buildChartSection(isDark),
              const SizedBox(height: 20),
              Text('Transactions',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 10),
              ..._buildTransactionList(isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: AppTheme.gradientAccent,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('💸 Expense Tracker',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        Text('Manage your income & expenses',
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ]),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final sel = f == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54))),
              selected: sel,
              onSelected: (_) => setState(() => _filter = f),
              selectedColor: AppTheme.accent,
              backgroundColor:
              isDark ? const Color(0xFF1A1A2E) : Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    return Row(children: [
      Expanded(
          child: _summaryCard('Income',
              '\$${_totalIncome.toStringAsFixed(0)}', AppTheme.success, '↑', isDark)),
      const SizedBox(width: 12),
      Expanded(
          child: _summaryCard('Expense',
              '\$${_totalExpense.toStringAsFixed(0)}', AppTheme.accent, '↓', isDark)),
      const SizedBox(width: 12),
      Expanded(
          child: _summaryCard(
              'Balance',
              '\$${(_totalIncome - _totalExpense).toStringAsFixed(0)}',
              AppTheme.primary,
              '=',
              isDark)),
    ]);
  }

  Widget _summaryCard(
      String label, String value, Color color, String icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(icon,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildChartSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
          labelStyle:
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Category Split'),
            Tab(text: 'Monthly Trend')
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: [
                ExpensePieChart(
                    data: _categoryData,
                    colors: [
                      AppTheme.food,
                      AppTheme.transport,
                      AppTheme.shopping,
                      AppTheme.bills,
                      AppTheme.other
                    ]),
                MonthlyBarChart(data: _monthlyData),
              ],
            )),
      ]),
    );
  }

  List<Widget> _buildTransactionList(bool isDark) {
    final list = _filtered;
    if (list.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
              child: Column(children: [
                const Text('📭', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                Text('No transactions found',
                    style:
                    GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
              ])),
        )
      ];
    }
    return list.map((e) {
      final isIncome = e.type == TransactionType.income;
      final color = isIncome ? AppTheme.success : _catColor(e.category);
      return Dismissible(
        key: Key(e.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.centerRight,
          child: const Icon(Icons.delete_outline, color: AppTheme.error),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text('Delete?',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              content: Text('Remove "${e.title}"?',
                  style: GoogleFonts.poppins(fontSize: 13)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete')),
              ],
            ),
          ) ??
              false;
        },
        onDismissed: (_) async {
          setState(() => _expenses.removeWhere((x) => x.id == e.id));
          await _save();
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('"${e.title}" deleted'),
                duration: const Duration(seconds: 2)));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text(isIncome ? '💰' : e.category.icon,
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
                child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(e.title,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87)),
                    if (e.isRecurring) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('🔁', style: TextStyle(fontSize: 9)),
                      ),
                    ],
                  ]),
                  Text(
                      '${e.category.label} • ${DateFormat('MMM d, yyyy').format(e.date)}',
                      style:
                      GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                ])),
            Text(
                '${isIncome ? '+' : '-'}\$${e.amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isIncome ? AppTheme.success : AppTheme.accent)),
          ]),
        ),
      );
    }).toList();
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    var type = TransactionType.expense;
    var category = ExpenseCategory.food;
    var recurring = false;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // FIX: Use useSafeArea so the sheet respects system insets properly
      useSafeArea: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          // FIX: Wrap everything in a SingleChildScrollView so that when the
          // keyboard appears and pushes content up, the form fields can still
          // scroll instead of overflowing.
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              // FIX: SingleChildScrollView prevents the 7.7px overflow when
              // the keyboard is visible, replacing the previous plain Column.
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Add Transaction',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // Income / Expense toggle
                  Row(children: [
                    Expanded(
                        child: _typeBtn(
                            'Income',
                            TransactionType.income,
                            type,
                            AppTheme.success,
                                () => setModal(() => type = TransactionType.income))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _typeBtn(
                            'Expense',
                            TransactionType.expense,
                            type,
                            AppTheme.accent,
                                () =>
                                setModal(() => type = TransactionType.expense))),
                  ]),
                  const SizedBox(height: 14),

                  // Title
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Title',
                        prefixIcon: Icon(Icons.edit_outlined)),
                  ),
                  const SizedBox(height: 10),

                  // Amount
                  TextField(
                    controller: amountCtrl,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        hintText: 'Amount',
                        prefixText: '\$ ',
                        prefixIcon: Icon(Icons.attach_money)),
                  ),
                  const SizedBox(height: 10),

                  // Category dropdown
                  DropdownButtonFormField<ExpenseCategory>(
                    value: category,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(category.icon,
                                style: const TextStyle(fontSize: 18)))),
                    items: ExpenseCategory.values
                        .map((c) => DropdownMenuItem(
                        value: c, child: Text(c.label)))
                        .toList(),
                    onChanged: (v) => setModal(() => category = v!),
                  ),
                  const SizedBox(height: 10),

                  // Date picker
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100));
                      if (d != null) setModal(() => selectedDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F0F1A)
                              : const Color(0xFFF0EFFF),
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 18),
                        const SizedBox(width: 12),
                        Text(DateFormat('MMM d, yyyy').format(selectedDate),
                            style: GoogleFonts.poppins(fontSize: 13)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Recurring toggle
                  Row(children: [
                    Switch(
                        value: recurring,
                        onChanged: (v) => setModal(() => recurring = v),
                        activeColor: AppTheme.primary),
                    Text('Recurring expense',
                        style: GoogleFonts.poppins(fontSize: 13)),
                  ]),
                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        final title = titleCtrl.text.trim();
                        final amount = double.tryParse(amountCtrl.text);
                        if (title.isEmpty || amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill all fields correctly')));
                          return;
                        }
                        final entry = ExpenseModel(
                          id: const Uuid().v4(),
                          title: title,
                          amount: amount,
                          category: category,
                          type: type,
                          date: selectedDate,
                          isRecurring: recurring,
                        );
                        setState(() => _expenses.insert(0, entry));
                        await _save();
                        if (mounted) Navigator.pop(context);
                      },
                      child: Text('Add Transaction',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  // Extra bottom padding so the button is never hidden behind
                  // the system navigation bar on gesture-nav devices.
                  SizedBox(
                      height: MediaQuery.of(ctx).padding.bottom > 0
                          ? MediaQuery.of(ctx).padding.bottom
                          : 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _typeBtn(String label, TransactionType t, TransactionType current,
      Color color, VoidCallback onTap) {
    final sel = t == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: sel ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Center(
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: sel ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13))),
      ),
    );
  }
}