import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';
import '../models/bill_model.dart';
import '../models/debt_model.dart';
import '../models/savings_model.dart';

class StorageService {
  static const _expensesKey = 'expenses_v1';
  static const _budgetKey = 'budget_v1';
  static const _billsKey = 'bills_v1';
  static const _debtsKey = 'debts_v1';
  static const _savingsKey = 'savings_v1';
  static const _currencyKey = 'currency_v1';
  static const _themeKey = 'theme_v1';

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) throw StateError('StorageService not initialised. Call init() first.');
    return _prefs!;
  }

  // ─── Theme ────────────────────────────────────────────────
  Future<void> saveTheme(bool isDark) async => _p.setBool(_themeKey, isDark);
  bool loadTheme() => _p.getBool(_themeKey) ?? true;

  // ─── Currency ─────────────────────────────────────────────
  Future<void> saveCurrency(String code) async => _p.setString(_currencyKey, code);
  String loadCurrency() => _p.getString(_currencyKey) ?? 'USD';

  // ─── Expenses ─────────────────────────────────────────────
  Future<void> saveExpenses(List<ExpenseModel> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _p.setString(_expensesKey, encoded);
  }

  List<ExpenseModel> loadExpenses() {
    final raw = _p.getString(_expensesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) { return []; }
  }

  // ─── Budget ───────────────────────────────────────────────
  Future<void> saveBudget(BudgetSettings settings) async {
    final encoded = jsonEncode(settings.toJson());
    await _p.setString(_budgetKey, encoded);
  }

  BudgetSettings loadBudget() {
    final raw = _p.getString(_budgetKey);
    if (raw == null || raw.isEmpty) return BudgetSettings.defaultSettings();
    try {
      return BudgetSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) { return BudgetSettings.defaultSettings(); }
  }

  // ─── Bills ────────────────────────────────────────────────
  Future<void> saveBills(List<BillModel> list) async {
    final encoded = jsonEncode(list.map((b) => b.toJson()).toList());
    await _p.setString(_billsKey, encoded);
  }

  List<BillModel> loadBills() {
    final raw = _p.getString(_billsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((b) => BillModel.fromJson(b as Map<String, dynamic>)).toList();
    } catch (_) { return []; }
  }

  // ─── Debts ────────────────────────────────────────────────
  Future<void> saveDebts(List<DebtModel> list) async {
    final encoded = jsonEncode(list.map((d) => d.toJson()).toList());
    await _p.setString(_debtsKey, encoded);
  }

  List<DebtModel> loadDebts() {
    final raw = _p.getString(_debtsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((d) => DebtModel.fromJson(d as Map<String, dynamic>)).toList();
    } catch (_) { return []; }
  }

  // ─── Savings ──────────────────────────────────────────────
  Future<void> saveSavings(List<SavingsGoal> list) async {
    final encoded = jsonEncode(list.map((s) => s.toJson()).toList());
    await _p.setString(_savingsKey, encoded);
  }

  List<SavingsGoal> loadSavings() {
    final raw = _p.getString(_savingsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((s) => SavingsGoal.fromJson(s as Map<String, dynamic>)).toList();
    } catch (_) { return []; }
  }

  // ─── Clear all ────────────────────────────────────────────
  Future<void> clearAll() async => _p.clear();
}