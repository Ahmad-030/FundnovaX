import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundnovax/responsive.dart';
import 'package:fundnovax/storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/debt_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
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
  late ThemeMode _themeMode;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _themeMode = StorageService.instance.loadTheme()
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void _toggleTheme() {
    final newDark = _themeMode != ThemeMode.dark;
    StorageService.instance.saveTheme(newDark);
    setState(
            () => _themeMode = newDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FundNovaX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: _showSplash
          ? SplashScreen(
          onComplete: () => setState(() => _showSplash = false))
          : MainShell(
          onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class MainShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const MainShell(
      {super.key,
        required this.onToggleTheme,
        required this.themeMode});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late PageController _pageController;
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currency = StorageService.instance.loadCurrency();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCurrencyChanged(String newCurrency) {
    setState(() => _currency = newCurrency);
  }

  void _navigateTo(int index) {
    if (index >= 5) {
      Navigator.push(
          context,
          _slideRoute(
              index == 5 ? const DebtScreen() : const AboutScreen()));
      return;
    }
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
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomeScreen(onNavigate: _navigateTo, currency: _currency),
              ExpenseScreen(currency: _currency),
              BudgetScreen(currency: _currency),
              BillScreen(currency: _currency),
              SavingsScreen(
                currency: _currency,
                onCurrencyChanged: _onCurrencyChanged,
              ),
            ],
          ),
          if (_currentIndex == 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: Responsive.hPad,
              child: _buildThemeToggle(isDark),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
      floatingActionButton:
      _currentIndex == 0 ? _buildMenuFAB() : null,
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    final size = Responsive.isXSmall ? 38.0 : 42.0;
    return GestureDetector(
      onTap: widget.onToggleTheme,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.3),
          borderRadius:
          BorderRadius.circular(Responsive.radiusSm),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: Colors.white,
          size: Responsive.isXSmall ? 17 : 20,
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.isXSmall ? 4 : 8,
            vertical: Responsive.isXSmall ? 6 : 8,
          ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: selected
                        ? (Responsive.isXSmall ? 10 : 16)
                        : (Responsive.isXSmall ? 8 : 12),
                    vertical: Responsive.isXSmall ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? (isDark
                        ? AppTheme.secondary.withOpacity(0.15)
                        : AppTheme.primary.withOpacity(0.1))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                        Responsive.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: Responsive.iconMd,
                        color: selected
                            ? (isDark
                            ? AppTheme.secondary
                            : AppTheme.primary)
                            : (isDark
                            ? Colors.white38
                            : Colors.black38),
                      ),
                      if (selected) ...[
                        SizedBox(
                            width: Responsive.isXSmall ? 4 : 6),
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontCaption,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppTheme.secondary
                                : AppTheme.primary,
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

  Widget _buildMenuFAB() {
    return FloatingActionButton(
      onPressed: () => _showQuickMenu(context),
      backgroundColor: AppTheme.primary,
      elevation: 6,
      child: Icon(Icons.grid_view_rounded,
          color: Colors.white,
          size: Responsive.isXSmall ? 20 : 24),
    );
  }

  void _showQuickMenu(BuildContext context) {
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: EdgeInsets.all(Responsive.isXSmall ? 12 : 16),
        padding: EdgeInsets.all(Responsive.isXSmall ? 16 : 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius:
          BorderRadius.circular(Responsive.radiusXl),
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
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: Responsive.isXSmall ? 12 : 16),
            Text(
              'Quick Navigate',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.fontTitle - 2,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(height: Responsive.isXSmall ? 12 : 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: Responsive.isXSmall ? 8 : 10,
              mainAxisSpacing: Responsive.isXSmall ? 8 : 10,
              childAspectRatio: Responsive.moduleCardAspect,
              children: [
                _menuItem(
                    '💸', 'Expenses', 1, AppTheme.accent, context),
                _menuItem(
                    '🎯', 'Budget', 2, AppTheme.primary, context),
                _menuItem(
                    '🔔', 'Bills', 3, AppTheme.warning, context),
                _menuItem(
                    '🤝', 'Debts', 5, AppTheme.secondary, context),
                _menuItem(
                    '🏦', 'Savings', 4, AppTheme.success, context),
                _menuItem(
                    'ℹ️', 'About', 6, Colors.purple, context),
              ],
            ),
            SizedBox(height: Responsive.isXSmall ? 4 : 8),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String emoji, String label, int idx, Color color,
      BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _navigateTo(idx);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius:
          BorderRadius.circular(Responsive.radiusMd),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji,
                  style: TextStyle(
                      fontSize: Responsive.isXSmall ? 20 : 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.fontCaption,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ]),
      ),
    );
  }

  PageRoute _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(
            parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}