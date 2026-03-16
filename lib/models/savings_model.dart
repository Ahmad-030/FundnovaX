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

class DepositEntry {
  final String id;
  final double amount;
  final DateTime date;

  DepositEntry({required this.id, required this.amount, required this.date});

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
  };

  factory DepositEntry.fromJson(Map<String, dynamic> json) => DepositEntry(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
  );
}

class SavingsGoal {
  final String id;
  final String name;
  final SavingsIcon icon;
  final double targetAmount;
  final String currency;
  final DateTime targetDate;
  final List<DepositEntry> depositEntries;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.currency,
    required this.targetDate,
    List<DepositEntry>? depositEntries,
  }) : depositEntries = depositEntries ?? [];

  double get savedAmount => depositEntries.fold(0, (s, d) => s + d.amount);
  double get remainingAmount => (targetAmount - savedAmount).clamp(0, double.infinity);
  double get progressPercent => targetAmount > 0 ? (savedAmount / targetAmount).clamp(0, 1) : 0;
  bool get isCompleted => savedAmount >= targetAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays.clamp(0, 99999);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon.index,
    'targetAmount': targetAmount,
    'currency': currency,
    'targetDate': targetDate.toIso8601String(),
    'depositEntries': depositEntries.map((d) => d.toJson()).toList(),
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: SavingsIcon.values[json['icon'] as int],
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currency: json['currency'] as String,
    targetDate: DateTime.parse(json['targetDate'] as String),
    depositEntries: (json['depositEntries'] as List? ?? [])
        .map((d) => DepositEntry.fromJson(d as Map<String, dynamic>))
        .toList(),
  );

  SavingsGoal copyWith({List<DepositEntry>? depositEntries}) => SavingsGoal(
    id: id, name: name, icon: icon,
    targetAmount: targetAmount, currency: currency, targetDate: targetDate,
    depositEntries: depositEntries ?? this.depositEntries,
  );
}