class CurrencyUtils {
  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'PKR', 'symbol': '₨', 'name': 'Pakistani Rupee'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
    {'code': 'SAR', 'symbol': '﷼', 'name': 'Saudi Riyal'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CHF', 'symbol': 'Fr', 'name': 'Swiss Franc'},
  ];

  static String getSymbol(String code) {
    return currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'symbol': code},
    )['symbol']!;
  }

  static String format(double amount, String currencyCode) {
    final symbol = getSymbol(currencyCode);
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatFull(double amount, String currencyCode) {
    final symbol = getSymbol(currencyCode);
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}
