import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/savings_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> with TickerProviderStateMixin {
  String _selectedCurrency = 'USD';

  final List<SavingsGoal> _goals = [
    SavingsGoal(id: '1', name: 'New iPhone', icon: SavingsIcon.phone, targetAmount: 1200, currency: 'USD', targetDate: DateTime.now().add(const Duration(days: 90)), deposits: [200, 150, 100]),
    SavingsGoal(id: '2', name: 'Europe Trip', icon: SavingsIcon.trip, targetAmount: 5000, currency: 'USD', targetDate: DateTime.now().add(const Duration(days: 180)), deposits: [500, 300]),
    SavingsGoal(id: '3', name: 'Dream Car', icon: SavingsIcon.car, targetAmount: 15000, currency: 'USD', targetDate: DateTime.now().add(const Duration(days: 730)), deposits: [1000, 500, 750, 250]),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSaved = _goals.fold(0.0, (s, g) => s + g.savedAmount);
    final totalTarget = _goals.fold(0.0, (s, g) => s + g.targetAmount);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDark, totalSaved, totalTarget),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrencySelector(isDark),
                  const SizedBox(height: 16),
                  Text('My Goals', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 12),
                  ..._goals.map((g) => _buildGoalCard(g, isDark)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: Text('New Goal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  Widget _buildHeader(bool isDark, double totalSaved, double totalTarget) {
    final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppTheme.gradientGreen, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏦 Savings Goals', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          Text('Build your future, one goal at a time', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Total Saved', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                    Text(CurrencyUtils.formatFull(totalSaved, _selectedCurrency), style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Target', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                    Text(CurrencyUtils.formatFull(totalTarget, _selectedCurrency), style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ]),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${(overallProgress * 100).toInt()}% achieved', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                  Text('${_goals.length} Goals', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButton<String>(
        value: _selectedCurrency,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: AppTheme.success),
        hint: Text('Currency', style: GoogleFonts.poppins()),
        items: CurrencyUtils.currencies.map((c) => DropdownMenuItem(
          value: c['code'],
          child: Text('${c['code']} (${c['symbol']}) — ${c['name']}', style: GoogleFonts.poppins(fontSize: 13)),
        )).toList(),
        onChanged: (v) => setState(() => _selectedCurrency = v!),
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal, bool isDark) {
    return _AnimatedGoalCard(goal: goal, currency: _selectedCurrency, isDark: isDark, onDeposit: () => _showDepositDialog(context, goal));
  }

  void _showDepositDialog(BuildContext context, SavingsGoal goal) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${goal.icon.emoji} Add to ${goal.name}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Remaining: ${CurrencyUtils.formatFull(goal.remainingAmount, _selectedCurrency)}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount', prefixText: '${CurrencyUtils.getSymbol(_selectedCurrency)} ')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
            onPressed: () {
              final amount = double.tryParse(ctrl.text) ?? 0;
              if (amount > 0) {
                setState(() {
                  final idx = _goals.indexWhere((g) => g.id == goal.id);
                  if (idx >= 0) {
                    final updated = List<double>.from(_goals[idx].deposits)..add(amount);
                    _goals[idx] = _goals[idx].copyWith(deposits: updated);
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

  void _showAddGoalDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    SavingsIcon icon = SavingsIcon.other;
    DateTime targetDate = DateTime.now().add(const Duration(days: 90));

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
                Text('Create Savings Goal', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SavingsIcon.values.map((i) {
                      final sel = i == icon;
                      return GestureDetector(
                        onTap: () => setModalState(() => icon = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: sel ? AppTheme.success.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: sel ? AppTheme.success : Colors.grey.shade300),
                          ),
                          child: Column(children: [
                            Text(i.emoji, style: const TextStyle(fontSize: 20)),
                            Text(i.label, style: GoogleFonts.poppins(fontSize: 9, color: sel ? AppTheme.success : Colors.grey)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Goal Name', prefixIcon: Icon(Icons.flag_outlined))),
                const SizedBox(height: 10),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount', prefixText: '\$ ')),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: targetDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 1825)));
                    if (picked != null) setModalState(() => targetDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF), borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.success),
                      const SizedBox(width: 12),
                      Text('Target Date: ${targetDate.day}/${targetDate.month}/${targetDate.year}', style: GoogleFonts.poppins(fontSize: 13)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                        setState(() {
                          _goals.add(SavingsGoal(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameCtrl.text,
                            icon: icon,
                            targetAmount: double.tryParse(amountCtrl.text) ?? 0,
                            currency: _selectedCurrency,
                            targetDate: targetDate,
                          ));
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Create Goal', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedGoalCard extends StatefulWidget {
  final SavingsGoal goal;
  final String currency;
  final bool isDark;
  final VoidCallback onDeposit;

  const _AnimatedGoalCard({required this.goal, required this.currency, required this.isDark, required this.onDeposit});

  @override
  State<_AnimatedGoalCard> createState() => _AnimatedGoalCardState();
}

class _AnimatedGoalCardState extends State<_AnimatedGoalCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = Tween<double>(begin: 0, end: widget.goal.progressPercent).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final isDark = widget.isDark;
    final gradients = [AppTheme.gradientPrimary, AppTheme.gradientAccent, AppTheme.gradientGreen, [AppTheme.warning, AppTheme.secondary]];
    final gi = widget.goal.id.hashCode.abs() % gradients.length;
    final colors = gradients[gi];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(goal.icon.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(goal.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('${goal.daysRemaining} days remaining', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                  ]),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                    child: Text('🏆 Done!', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Saved', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    Text(CurrencyUtils.formatFull(goal.savedAmount, widget.currency), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: colors[0])),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Target', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    Text(CurrencyUtils.formatFull(goal.targetAmount, widget.currency), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                  ]),
                ]),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Column(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _anim.value,
                        minHeight: 10,
                        backgroundColor: colors[0].withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(colors[0]),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${(_anim.value * 100).toInt()}% complete', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                      Text(CurrencyUtils.formatFull(goal.remainingAmount, widget.currency) + ' left', style: GoogleFonts.poppins(fontSize: 11, color: colors[0], fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                ),
                if (!goal.isCompleted) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors[0], foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: widget.onDeposit,
                      child: Text('Add Money', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('🎉 Goal Achieved! Congratulations!', style: GoogleFonts.poppins(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 13))),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
