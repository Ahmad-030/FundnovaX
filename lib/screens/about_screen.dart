import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                children: [
                  _buildAppCard(isDark),
                  const SizedBox(height: 16),
                  _buildDevCard(isDark),
                  const SizedBox(height: 16),
                  _buildPrivacyButton(context, isDark),
                  const SizedBox(height: 16),
                  _buildFeaturesList(isDark),
                  const SizedBox(height: 24),
                  Text('Made with ❤️ by A List Virtual Solution LLC', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppTheme.gradientDark, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppTheme.gradientPrimary),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: const Center(child: Text('🏦', style: TextStyle(fontSize: 40))),
        ),
        const SizedBox(height: 14),
        Text('FundNovaX', style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
        Text('Personal Finance Manager', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 13)),
      ]),
    );
  }

  Widget _buildAppCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About FundNovaX', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            'FundNovaX is a modern, all-in-one personal finance app designed to help you take control of your money. Track expenses, plan budgets, manage bills, track debts, and achieve your savings goals — all in one beautiful app.',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildDevCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppTheme.gradientPrimary, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('👨‍💻', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Developer', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.75), fontSize: 11)),
                Text('A List Virtual Solution LLC', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Text('mr.androidstudio@gmail.com', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Privacy Policy', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
              Text('Read our data practices', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primary),
        ]),
      ),
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final features = [
      {'icon': '💸', 'title': 'Expense Tracker', 'desc': 'Track income & expenses with charts'},
      {'icon': '🎯', 'title': 'Budget Planner', 'desc': 'Set and monitor spending budgets'},
      {'icon': '🔔', 'title': 'Bill Reminder', 'desc': 'Never miss a payment deadline'},
      {'icon': '🤝', 'title': 'Debt Tracker', 'desc': 'Manage money lent and borrowed'},
      {'icon': '🏦', 'title': 'Savings Goals', 'desc': 'Work towards your financial goals'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Features', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Text(f['icon']!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f['title']!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(f['desc']!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ]),
            ]),
          )),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadFlutterAsset('assets/privacy_policy.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        ],
      ),
    );
  }
}
