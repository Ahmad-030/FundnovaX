enum SavingsIcon { phone, car, trip, home, laptop, watch, gift, other }

extension SavingsIconExt on SavingsIcon {
  String get emoji {
    switch (this) {
      case SavingsIcon.phone: return '📱';
      case SavingsIcon.car: return '🚗';
      case SavingsIcon.trip: return '✈️';
      case SavingsIcon.home: return '🏡';
      case SavingsIcon.laptop: return '💻';
      case SavingsIcon.watch: return '⌚';
      case SavingsIcon.gift: return '🎁';
      case SavingsIcon.other: return '🎯';
    }
  }

  String get label {
    switch (this) {
      case SavingsIcon.phone: return 'Phone';
      case SavingsIcon.car: return 'Car';
      case SavingsIcon.trip: return 'Trip';
      case SavingsIcon.home: return 'Home';
      case SavingsIcon.laptop: return 'Laptop';
      case SavingsIcon.watch: return 'Watch';
      case SavingsIcon.gift: return 'Gift';
      case SavingsIcon.other: return 'Other';
    }
  }
}

class SavingsGoal {
  final String id;
  final String name;
  final SavingsIcon icon;
  final double targetAmount;
  final String currency;
  final DateTime targetDate;
  final List<double> deposits;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.currency,
    required this.targetDate,
    List<double>? deposits,
  }) : deposits = deposits ?? [];

  double get savedAmount => deposits.fold(0, (s, d) => s + d);
  double get remainingAmount => (targetAmount - savedAmount).clamp(0, double.infinity);
  double get progressPercent => targetAmount > 0 ? (savedAmount / targetAmount).clamp(0, 1) : 0;
  bool get isCompleted => savedAmount >= targetAmount;

  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays.clamp(0, 99999);
  }

  SavingsGoal copyWith({List<double>? deposits}) {
    return SavingsGoal(
      id: id,
      name: name,
      icon: icon,
      targetAmount: targetAmount,
      currency: currency,
      targetDate: targetDate,
      deposits: deposits ?? this.deposits,
    );
  }
}
