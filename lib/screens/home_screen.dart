import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnims = List.generate(6, (i) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(i * 0.12, 0.6 + i * 0.08, curve: Curves.easeOut)),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animatedItem(0, _buildQuickStats(isDark)),
                  const SizedBox(height: 24),
                  _animatedItem(1, Text('Quick Access', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87))),
                  const SizedBox(height: 14),
                  _animatedItem(2, _buildModuleGrid()),
                  const SizedBox(height: 24),
                  _animatedItem(3, _buildTipCard(isDark)),
                  const SizedBox(height: 24),
                  _animatedItem(4, _buildRecentActivity(isDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedItem(int i, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[i],
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Interval(i * 0.1, 0.6 + i * 0.1, curve: Curves.easeOut)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppTheme.gradientPrimary, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back 👋', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  Text('FundNovaX', style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                ],
              ),
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Balance', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    Text('\$24,580.00', style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('+3.2% this month', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                    ]),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _miniStat('Income', '\$6,200', '↑', const Color(0xFF4CAF50)),
                    const SizedBox(height: 10),
                    _miniStat('Expense', '\$2,840', '↓', const Color(0xFFFF6584)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String val, String arrow, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 10)),
        Row(
          children: [
            Text(arrow, style: TextStyle(color: color, fontSize: 12)),
            const SizedBox(width: 2),
            Text(val, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        SummaryStatCard(label: 'Active Bills', value: '5', color: AppTheme.warning, icon: '🔔'),
        SummaryStatCard(label: 'Savings Goals', value: '3', color: AppTheme.secondary, icon: '🏦'),
        SummaryStatCard(label: 'Budget Used', value: '68%', color: AppTheme.primary, icon: '🎯'),
        SummaryStatCard(label: 'Debts Tracked', value: '2', color: AppTheme.accent, icon: '🤝'),
      ],
    );
  }

  Widget _buildModuleGrid() {
    final modules = [
      {'icon': '💸', 'label': 'Expenses', 'idx': 1, 'color': AppTheme.accent},
      {'icon': '🎯', 'label': 'Budget', 'idx': 2, 'color': AppTheme.primary},
      {'icon': '🔔', 'label': 'Bills', 'idx': 3, 'color': AppTheme.warning},
      {'icon': '🤝', 'label': 'Debts', 'idx': 4, 'color': AppTheme.secondary},
      {'icon': '🏦', 'label': 'Savings', 'idx': 5, 'color': AppTheme.success},
      {'icon': 'ℹ️', 'label': 'About', 'idx': 6, 'color': Colors.purple},
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: modules.map((m) {
        final color = m['color'] as Color;
        return GestureDetector(
          onTap: () => widget.onNavigate(m['idx'] as int),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(m['icon'] as String, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(m['label'] as String, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTipCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Finance Tip', style: GoogleFonts.poppins(color: AppTheme.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Follow the 50/30/20 rule: 50% needs, 30% wants, 20% savings.',
                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    final items = [
      {'icon': '🍔', 'label': 'Food & Dining', 'date': 'Today', 'amount': '-\$24.50', 'isExp': true},
      {'icon': '💰', 'label': 'Salary Credit', 'date': 'Yesterday', 'amount': '+\$3,200', 'isExp': false},
      {'icon': '🚗', 'label': 'Transport', 'date': 'Dec 14', 'amount': '-\$12.00', 'isExp': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
            TextButton(
              onPressed: () => widget.onNavigate(1),
              child: Text('See All', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(item['icon'] as String, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['label'] as String, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    Text(item['date'] as String, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                item['amount'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: (item['isExp'] as bool) ? AppTheme.accent : AppTheme.success,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
