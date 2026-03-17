import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/savings_model.dart';
import '../responsive.dart';
import '../storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';

class SavingsScreen extends StatefulWidget {
  final String currency;
  final ValueChanged<String> onCurrencyChanged;

  const SavingsScreen({
    super.key,
    required this.currency,
    required this.onCurrencyChanged,
  });

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with TickerProviderStateMixin {
  List<SavingsGoal> _goals = [];

  // Local mirror so the dropdown feels instant
  late String _currency;

  @override
  void initState() {
    super.initState();
    _currency = widget.currency;
    _load();
  }

  @override
  void didUpdateWidget(SavingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currency != widget.currency) {
      setState(() => _currency = widget.currency);
    }
  }

  void _load() {
    setState(() {
      _goals = StorageService.instance.loadSavings();
    });
  }

  Future<void> _save() => StorageService.instance.saveSavings(_goals);

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSaved =
    _goals.fold(0.0, (s, g) => s + g.savedAmount);
    final totalTarget =
    _goals.fold(0.0, (s, g) => s + g.targetAmount);

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0EFFF),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        color: AppTheme.success,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            _buildHeader(isDark, totalSaved, totalTarget),
            Padding(
              padding: EdgeInsets.all(Responsive.hPad),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrencySelector(isDark),
                    SizedBox(height: Responsive.vGap),
                    Text(
                      'My Goals',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.fontTitle,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: Responsive.isXSmall ? 8 : 12),
                    if (_goals.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ..._goals.map((g) => _AnimatedGoalCard(
                        key: ValueKey(g.id),
                        goal: g,
                        currency: _currency,
                        isDark: isDark,
                        onDeposit: () =>
                            _showDepositDialog(context, g),
                        onDelete: () => _deleteGoal(g.id),
                      )),
                    const SizedBox(height: 100),
                  ]),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: Text('New Goal',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  Widget _buildHeader(
      bool isDark, double totalSaved, double totalTarget) {
    final overallProgress = totalTarget > 0
        ? (totalSaved / totalTarget).clamp(0.0, 1.0)
        : 0.0;
    final topPad = Responsive.headerTop(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          Responsive.hPad, topPad, Responsive.hPad, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: AppTheme.gradientGreen,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          '🏦 Savings Goals',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: Responsive.fontTitle + 4,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Build your future, one goal at a time',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: Responsive.fontCaption + 1,
          ),
        ),
        SizedBox(height: Responsive.vGap + 4),
        Container(
          padding: EdgeInsets.all(Responsive.isXSmall ? 12 : 16),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(Responsive.radiusMd)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Saved',
                            style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: Responsive.fontCaption),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyUtils.formatFull(totalSaved, _currency),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: Responsive.isXSmall ? 18 : 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      'Target',
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: Responsive.fontCaption),
                    ),
                    Text(
                      CurrencyUtils.formatFull(totalTarget, _currency),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: Responsive.isXSmall ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ]),
                ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                '${(overallProgress * 100).toInt()}% achieved',
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: Responsive.fontCaption),
              ),
              Text(
                '${_goals.length} Goal${_goals.length != 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: Responsive.fontCaption),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCurrencySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius:
          BorderRadius.circular(Responsive.radiusMd)),
      child: DropdownButton<String>(
        value: _currency,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.success),
        style: TextStyle(
            fontSize: Responsive.fontBody,
            color: isDark ? Colors.white : Colors.black87),
        items: CurrencyUtils.currencies
            .map((c) => DropdownMenuItem(
          value: c['code'],
          child: Text(
              '${c['code']} (${c['symbol']}) — ${c['name']}',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.fontBody)),
        ))
            .toList(),
        onChanged: (v) async {
          if (v == null) return;
          setState(() => _currency = v);
          await StorageService.instance.saveCurrency(v);
          // Notify parent so all other screens update immediately
          widget.onCurrencyChanged(v);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: EdgeInsets.all(Responsive.isXSmall ? 24 : 36),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius:
          BorderRadius.circular(Responsive.radiusLg)),
      child: Center(
        child: Column(children: [
          Text('🏦',
              style: TextStyle(
                  fontSize: Responsive.isXSmall ? 36 : 48)),
          const SizedBox(height: 16),
          Text('No Savings Goals',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.fontTitle,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Tap "New Goal" to start saving towards something you love.',
            style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: Responsive.fontCaption + 1),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }

  Future<void> _deleteGoal(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(Responsive.radiusLg)),
        title: Text('Delete Goal?',
            style:
            GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: const Text(
            'This will remove the goal and all deposits.'),
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
    );
    if (confirm == true) {
      setState(() => _goals.removeWhere((g) => g.id == id));
      await _save();
    }
  }

  void _showDepositDialog(BuildContext context, SavingsGoal goal) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(Responsive.radiusLg)),
        title: Text(
          '${goal.icon.emoji} Add to ${goal.name}',
          style:
          GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Remaining: ${CurrencyUtils.formatFull(goal.remainingAmount, _currency)}',
            style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: Responsive.fontCaption + 1),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: 'Amount',
                prefixText:
                '${CurrencyUtils.getSymbol(_currency)} '),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white),
            onPressed: () async {
              final amount = double.tryParse(ctrl.text);
              if (amount == null || amount <= 0) return;
              final idx =
              _goals.indexWhere((g) => g.id == goal.id);
              if (idx >= 0) {
                final updated =
                List<DepositEntry>.from(_goals[idx].depositEntries)
                  ..add(DepositEntry(
                      id: const Uuid().v4(),
                      amount: amount,
                      date: DateTime.now()));
                setState(() => _goals[idx] =
                    _goals[idx].copyWith(depositEntries: updated));
                await _save();
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    Responsive.init(context);
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    var icon = SavingsIcon.other;
    var targetDate =
    DateTime.now().add(const Duration(days: 90));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
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
                  Text('Create Savings Goal',
                      style: GoogleFonts.poppins(
                          fontSize: Responsive.fontTitle,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: Responsive.isXSmall ? 10 : 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: SavingsIcon.values.map((i) {
                        final sel = i == icon;
                        return GestureDetector(
                          onTap: () => setModal(() => icon = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: EdgeInsets.all(
                                Responsive.isXSmall ? 8 : 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppTheme.success.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                  Responsive.radiusSm),
                              border: Border.all(
                                  color: sel
                                      ? AppTheme.success
                                      : Colors.grey.shade300),
                            ),
                            child: Column(children: [
                              Text(i.emoji,
                                  style: TextStyle(
                                      fontSize: Responsive.isXSmall
                                          ? 16
                                          : 20)),
                              Text(
                                i.label,
                                style: GoogleFonts.poppins(
                                    fontSize: Responsive.fontCaption - 1,
                                    color: sel
                                        ? AppTheme.success
                                        : Colors.grey),
                              ),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: Responsive.isXSmall ? 8 : 10),
                  TextField(
                    controller: nameCtrl,
                    style:
                    TextStyle(fontSize: Responsive.fontBody),
                    decoration: const InputDecoration(
                        labelText: 'Goal Name',
                        prefixIcon: Icon(Icons.flag_outlined)),
                  ),
                  SizedBox(height: Responsive.isXSmall ? 8 : 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style:
                    TextStyle(fontSize: Responsive.fontBody),
                    decoration: const InputDecoration(
                        labelText: 'Target Amount',
                        prefixText: '\$ '),
                  ),
                  SizedBox(height: Responsive.isXSmall ? 8 : 10),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100));
                      if (d != null)
                        setModal(() => targetDate = d);
                    },
                    child: Container(
                      padding: EdgeInsets.all(
                          Responsive.isXSmall ? 12 : 14),
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F0F1A)
                              : const Color(0xFFF0EFFF),
                          borderRadius: BorderRadius.circular(
                              Responsive.radiusMd)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppTheme.success),
                        SizedBox(
                            width: Responsive.isXSmall ? 8 : 12),
                        Text(
                          'Target Date: ${DateFormat('MMM d, yyyy').format(targetDate)}',
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.fontBody),
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(height: Responsive.isXSmall ? 12 : 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical:
                              Responsive.isXSmall ? 12 : 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Responsive.radiusMd))),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final amount =
                        double.tryParse(amountCtrl.text);
                        if (name.isEmpty ||
                            amount == null ||
                            amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill all fields')));
                          return;
                        }
                        final goal = SavingsGoal(
                            id: const Uuid().v4(),
                            name: name,
                            icon: icon,
                            targetAmount: amount,
                            currency: _currency,
                            targetDate: targetDate);
                        setState(() => _goals.add(goal));
                        await _save();
                        if (mounted) Navigator.pop(context);
                      },
                      child: Text('Create Goal',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: Responsive.fontBody)),
                    ),
                  ),
                ]),
          );
        },
      ),
    );
  }
}

// ── Animated goal card ────────────────────────────────────────────────────────
class _AnimatedGoalCard extends StatefulWidget {
  final SavingsGoal goal;
  final String currency;
  final bool isDark;
  final VoidCallback onDeposit;
  final VoidCallback onDelete;

  const _AnimatedGoalCard(
      {super.key,
        required this.goal,
        required this.currency,
        required this.isDark,
        required this.onDeposit,
        required this.onDelete});

  @override
  State<_AnimatedGoalCard> createState() =>
      _AnimatedGoalCardState();
}

class _AnimatedGoalCardState extends State<_AnimatedGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(
        begin: 0, end: widget.goal.progressPercent)
        .animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final goal = widget.goal;
    final gradients = [
      AppTheme.gradientPrimary,
      AppTheme.gradientAccent,
      AppTheme.gradientGreen,
      [AppTheme.warning, AppTheme.secondary]
    ];
    final colors =
    gradients[goal.id.hashCode.abs() % gradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color:
        widget.isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius:
        BorderRadius.circular(Responsive.radiusLg),
        boxShadow: [
          BoxShadow(
              color: colors[0].withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        Container(
          padding: EdgeInsets.all(Responsive.isXSmall ? 12 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Responsive.radiusLg)),
          ),
          child: Row(children: [
            Text(goal.icon.emoji,
                style: TextStyle(
                    fontSize: Responsive.isXSmall ? 26 : 32)),
            SizedBox(width: Responsive.isXSmall ? 8 : 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: Responsive.fontBody + 2,
                          fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${goal.daysRemaining} days remaining',
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: Responsive.fontCaption),
                    ),
                  ]),
            ),
            GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_outline,
                    color: Colors.white, size: 16),
              ),
            ),
            if (goal.isCompleted) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('🏆 Done!',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: Responsive.fontCaption,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
        ),
        Padding(
          padding: EdgeInsets.all(Responsive.isXSmall ? 12 : 16),
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saved',
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.fontCaption,
                                color: Colors.grey)),
                        Text(
                          CurrencyUtils.formatFull(
                              goal.savedAmount, widget.currency),
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.isXSmall ? 16 : 18,
                              fontWeight: FontWeight.w800,
                              color: colors[0]),
                        ),
                      ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Target',
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.fontCaption,
                                color: Colors.grey)),
                        Text(
                          CurrencyUtils.formatFull(
                              goal.targetAmount, widget.currency),
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.isXSmall ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black87),
                        ),
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
                      valueColor:
                      AlwaysStoppedAnimation<Color>(colors[0])),
                ),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(_anim.value * 100).toInt()}% complete',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.fontCaption,
                            color: Colors.grey),
                      ),
                      Text(
                        '${CurrencyUtils.formatFull(goal.remainingAmount, widget.currency)} left',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.fontCaption,
                            color: colors[0],
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
              ]),
            ),
            const SizedBox(height: 12),
            if (!goal.isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colors[0],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical:
                          Responsive.isXSmall ? 8 : 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              Responsive.radiusSm))),
                  onPressed: widget.onDeposit,
                  child: Text('Add Money',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: Responsive.fontBody)),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: Responsive.isXSmall ? 8 : 10),
                decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        Responsive.radiusSm)),
                child: Center(
                  child: Text(
                    '🎉 Goal Achieved! Congratulations!',
                    style: GoogleFonts.poppins(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.fontCaption + 1),
                  ),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}