import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/debt_model.dart';
import '../theme/app_theme.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<DebtModel> _debts = [
    DebtModel(id: '1', type: DebtType.lent, contactName: 'Ahmed Khan', totalAmount: 500, dueDate: DateTime.now().add(const Duration(days: 15)), note: 'For car repair', payments: [PaymentEntry(id: 'p1', amount: 200, date: DateTime.now().subtract(const Duration(days: 5)))]),
    DebtModel(id: '2', type: DebtType.borrowed, contactName: 'Sara Ali', totalAmount: 300, dueDate: DateTime.now().add(const Duration(days: 30)), note: 'Emergency loan'),
    DebtModel(id: '3', type: DebtType.lent, contactName: 'Raza Mirza', totalAmount: 150, dueDate: DateTime.now().add(const Duration(days: 7)), payments: [PaymentEntry(id: 'p2', amount: 150, date: DateTime.now().subtract(const Duration(days: 1)))]),
  ];

  List<DebtModel> get _lent => _debts.where((d) => d.type == DebtType.lent).toList();
  List<DebtModel> get _borrowed => _debts.where((d) => d.type == DebtType.borrowed).toList();
  double get _totalLent => _lent.fold(0, (s, d) => s + d.remainingAmount);
  double get _totalBorrowed => _borrowed.fold(0, (s, d) => s + d.remainingAmount);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF),
      body: Column(
        children: [
          _buildHeader(isDark),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSummary(isDark),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1A2E) : Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.secondary,
                    unselectedLabelColor: Colors.grey,
                    indicator: BoxDecoration(color: AppTheme.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: [Tab(text: '📤 Lent (\$${_totalLent.toStringAsFixed(0)})'), Tab(text: '📥 Borrowed (\$${_totalBorrowed.toStringAsFixed(0)})')],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDebtList(_lent, isDark),
                _buildDebtList(_borrowed, isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context),
        backgroundColor: AppTheme.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3ECFCF), Color(0xFF6C63FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🤝 Debt Tracker', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          Text('Track money lent & borrowed', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isDark) {
    final net = _totalLent - _totalBorrowed;
    final isPositive = net >= 0;
    return Row(
      children: [
        Expanded(child: _summaryCard('You Lent', '\$${_totalLent.toStringAsFixed(2)}', AppTheme.success, '📤', isDark)),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('You Owe', '\$${_totalBorrowed.toStringAsFixed(2)}', AppTheme.error, '📥', isDark)),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('Net', '${isPositive ? '+' : ''}\$${net.abs().toStringAsFixed(0)}', isPositive ? AppTheme.success : AppTheme.error, isPositive ? '📈' : '📉', isDark)),
      ],
    );
  }

  Widget _summaryCard(String label, String value, Color color, String icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildDebtList(List<DebtModel> debts, bool isDark) {
    if (debts.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🤝', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No records yet', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
      itemCount: debts.length,
      itemBuilder: (_, i) => _buildDebtCard(debts[i], isDark),
    );
  }

  Widget _buildDebtCard(DebtModel debt, bool isDark) {
    final isLent = debt.type == DebtType.lent;
    final color = isLent ? AppTheme.success : AppTheme.error;
    final daysLeft = debt.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: debt.isSettled ? Border.all(color: AppTheme.success.withOpacity(0.3)) : (isOverdue ? Border.all(color: AppTheme.error.withOpacity(0.3)) : null),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(23)),
                child: Center(child: Text(debt.contactName.isNotEmpty ? debt.contactName[0].toUpperCase() : '?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(debt.contactName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                  if (debt.note != null) Text(debt.note!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('\$${debt.totalAmount.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
                Text(debt.isSettled ? '✅ Settled' : (isOverdue ? '⚠️ Overdue' : '$daysLeft days'),
                  style: GoogleFonts.poppins(fontSize: 10, color: debt.isSettled ? AppTheme.success : (isOverdue ? AppTheme.error : Colors.grey), fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
          if (!debt.isSettled) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: debt.progressPercent,
                minHeight: 6,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Paid: \$${debt.paidAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.success)),
              Text('Remaining: \$${debt.remainingAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showPaymentDialog(context, debt),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
                child: Center(child: Text('Add Payment', style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('✅ Fully Settled', style: GoogleFonts.poppins(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w600))),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, DebtModel debt) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Remaining: \$${debt.remainingAmount.toStringAsFixed(2)}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Payment Amount', prefixText: '\$ ')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, foregroundColor: Colors.white),
            onPressed: () {
              final amount = double.tryParse(ctrl.text) ?? 0;
              if (amount > 0) {
                setState(() {
                  final idx = _debts.indexWhere((d) => d.id == debt.id);
                  if (idx >= 0) {
                    final updated = List<PaymentEntry>.from(_debts[idx].payments)
                      ..add(PaymentEntry(id: DateTime.now().millisecondsSinceEpoch.toString(), amount: amount, date: DateTime.now()));
                    _debts[idx] = _debts[idx].copyWith(payments: updated);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DebtType type = DebtType.lent;
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Add Debt Record', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _typeBtn2('📤 Lent', DebtType.lent, type, AppTheme.success, () => setModalState(() => type = DebtType.lent))),
                  const SizedBox(width: 12),
                  Expanded(child: _typeBtn2('📥 Borrowed', DebtType.borrowed, type, AppTheme.error, () => setModalState(() => type = DebtType.borrowed))),
                ]),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Contact Name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 10),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ ')),
                const SizedBox(height: 10),
                TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.note_outlined))),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                        setState(() {
                          _debts.add(DebtModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            type: type,
                            contactName: nameCtrl.text,
                            totalAmount: double.tryParse(amountCtrl.text) ?? 0,
                            dueDate: dueDate,
                            note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
                          ));
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save Record', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _typeBtn2(String label, DebtType t, DebtType current, Color color, VoidCallback onTap) {
    final sel = t == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: sel ? color : color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(label, style: GoogleFonts.poppins(color: sel ? Colors.white : color, fontWeight: FontWeight.w600, fontSize: 13))),
      ),
    );
  }
}
