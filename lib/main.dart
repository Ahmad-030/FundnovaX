import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/debt_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/about_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const FundNovaXApp());
}

class FundNovaXApp extends StatefulWidget {
  const FundNovaXApp({super.key});

  @override
  State<FundNovaXApp> createState() => _FundNovaXAppState();
}

class _FundNovaXAppState extends State<FundNovaXApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FundNovaX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: MainShell(onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class MainShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const MainShell({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Expenses'),
    _NavItem(icon: Icons.pie_chart_rounded, label: 'Budget'),
    _NavItem(icon: Icons.notifications_rounded, label: 'Bills'),
    _NavItem(icon: Icons.savings_rounded, label: 'Savings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomeScreen(onNavigate: _navigateTo),
              const ExpenseScreen(),
              const BudgetScreen(),
              const BillScreen(),
              const SavingsScreen(),
              const DebtScreen(),
              const AboutScreen(),
            ],
          ),
          // Theme toggle + extra nav overlay
          Positioned(
            top: 56,
            right: 16,
            child: _currentIndex == 0
                ? _buildThemeToggle(isDark)
                : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
      floatingActionButton: _currentIndex == 0 ? _buildMenuFAB(isDark) : null,
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return GestureDetector(
      onTap: widget.onToggleTheme,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final selected = _currentIndex == i;
              final item = _navItems[i];
              return GestureDetector(
                onTap: () => _navigateTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? (isDark ? AppTheme.secondary.withOpacity(0.15) : AppTheme.primary.withOpacity(0.1))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: selected
                            ? (isDark ? AppTheme.secondary : AppTheme.primary)
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.secondary : AppTheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuFAB(bool isDark) {
    return FloatingActionButton(
      onPressed: () => _showQuickMenu(context),
      backgroundColor: AppTheme.primary,
      elevation: 6,
      child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
    );
  }

  void _showQuickMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Quick Navigate', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
              children: [
                _menuItem('💸', 'Expenses', 1, AppTheme.accent, context),
                _menuItem('🎯', 'Budget', 2, AppTheme.primary, context),
                _menuItem('🔔', 'Bills', 3, AppTheme.warning, context),
                _menuItem('🤝', 'Debts', 5, AppTheme.secondary, context),
                _menuItem('🏦', 'Savings', 4, AppTheme.success, context),
                _menuItem('ℹ️', 'About', 6, Colors.purple, context),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String emoji, String label, int idx, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (idx <= 4) {
          _navigateTo(idx);
        } else {
          Navigator.push(context, _slideRoute(idx == 5 ? const DebtScreen() : const AboutScreen()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  PageRoute _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
