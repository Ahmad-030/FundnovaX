import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/bill_model.dart';
import '../storage_service.dart';
import '../theme/app_theme.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});
  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<BillModel> _bills = [];
  String _filter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Paid', 'Late'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _bills = StorageService.instance.loadBills());
  Future<void> _save() => StorageService.instance.saveBills(_bills);

  List<BillModel> get _filtered {
    switch (_filter) {
      case 'Pending': return _bills.where((b) => b.status == BillStatus.pending).toList();
      case 'Paid': return _bills.where((b) => b.status == BillStatus.paid).toList();
      case 'Late': return _bills.where((b) => b.status == BillStatus.late).toList();
      default: return List.from(_bills)..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
  }

  double get _totalDue => _bills.where((b) => !b.isPaid).fold(0, (s, b) => s + b.amount);
  double get _totalPaid => _bills.where((b) => b.isPaid).fold(0, (s, b) => s + b.amount);
  int get _lateCount => _bills.where((b) => b.status == BillStatus.late).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        color: AppTheme.warning,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            _buildHeader(isDark),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_lateCount > 0) _buildLateWarning(),
                if (_lateCount > 0) const SizedBox(height: 12),
                _buildSummaryRow(isDark),
                const SizedBox(height: 16),
                _buildFilterChips(isDark),
                const SizedBox(height: 14),
                if (_filtered.isEmpty) _buildEmptyState(isDark)
                else ..._filtered.map((b) => _buildBillCard(b, isDark)),
                const SizedBox(height: 100),
              ]),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBillDialog(context),
        backgroundColor: AppTheme.warning,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF6584)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🔔 Bill Reminder', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        Text('Never miss a payment again', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ]),
    );
  }

  Widget _buildLateWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: AppTheme.error),
        const SizedBox(width: 10),
        Expanded(child: Text('⚠️ You have $_lateCount overdue bill${_lateCount > 1 ? 's' : ''}!',
            style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildSummaryRow(bool isDark) {
    return Row(children: [
      Expanded(child: _statCard('Total Due', '\$${_totalDue.toStringAsFixed(2)}', AppTheme.accent, isDark)),
      const SizedBox(width: 12),
      Expanded(child: _statCard('Paid', '\$${_totalPaid.toStringAsFixed(2)}', AppTheme.success, isDark)),
      const SizedBox(width: 12),
      Expanded(child: _statCard('Total', '${_bills.length}', AppTheme.primary, isDark)),
    ]);
  }

  Widget _statCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
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
              label: Text(f, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.grey)),
              selected: sel,
              onSelected: (_) => setState(() => _filter = f),
              selectedColor: AppTheme.warning,
              backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: Column(children: [
        const Text('🔔', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text('No Bills Found', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
        Text('Tap + to add your first bill', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
      ])),
    );
  }

  Widget _buildBillCard(BillModel bill, bool isDark) {
    final status = bill.status;
    Color statusColor;
    String statusLabel;
    switch (status) {
      case BillStatus.paid: statusColor = AppTheme.success; statusLabel = 'Paid'; break;
      case BillStatus.late: statusColor = AppTheme.error; statusLabel = 'Late'; break;
      default: statusColor = AppTheme.warning; statusLabel = 'Pending';
    }
    final daysLeft = bill.daysUntilDue;

    return Dismissible(
      key: Key(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: AppTheme.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Delete Bill?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: Text('Remove "${bill.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) async {
        setState(() => _bills.removeWhere((b) => b.id == bill.id));
        await _save();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: status == BillStatus.late ? Border.all(color: AppTheme.error.withOpacity(0.3)) : null,
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(bill.type.icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bill.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 2),
            Text(
                status == BillStatus.paid ? 'Paid ✓' : status == BillStatus.late ? '${-daysLeft}d overdue' : '$daysLeft days left',
                style: GoogleFonts.poppins(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
            Text('Due: ${DateFormat('MMM d, yyyy').format(bill.dueDate)}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${bill.amount.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                setState(() => bill.isPaid = !bill.isPaid);
                await _save();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withOpacity(0.3))),
                child: Text(statusLabel, style: GoogleFonts.poppins(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _showAddBillDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    var type = BillType.electricity;
    var dueDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Add Bill', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              DropdownButtonFormField<BillType>(
                value: type,
                decoration: const InputDecoration(labelText: 'Bill Type'),
                items: BillType.values.map((t) => DropdownMenuItem(value: t, child: Row(children: [Text(t.icon), const SizedBox(width: 8), Text(t.label)]))).toList(),
                onChanged: (v) => setModal(() => type = v!),
              ),
              const SizedBox(height: 10),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Bill Name', prefixIcon: Icon(Icons.receipt_outlined))),
              const SizedBox(height: 10),
              TextField(controller: amountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ ', prefixIcon: Icon(Icons.attach_money))),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: dueDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (picked != null) setModal(() => dueDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 12),
                    Text('Due: ${DateFormat('MMM d, yyyy').format(dueDate)}', style: GoogleFonts.poppins(fontSize: 13)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text);
                    if (name.isEmpty || amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }
                    final bill = BillModel(id: const Uuid().v4(), type: type, name: name, amount: amount, dueDate: dueDate);
                    setState(() => _bills.add(bill));
                    await _save();
                    if (mounted) Navigator.pop(context);
                  },
                  child: Text('Add Bill', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}