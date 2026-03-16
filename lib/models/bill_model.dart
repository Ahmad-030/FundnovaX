enum BillType { electricity, gas, internet, rent, other }
enum BillStatus { paid, pending, late }

extension BillTypeExt on BillType {
  String get label {
    switch (this) {
      case BillType.electricity: return 'Electricity';
      case BillType.gas: return 'Gas';
      case BillType.internet: return 'Internet';
      case BillType.rent: return 'Rent';
      case BillType.other: return 'Other';
    }
  }
  String get icon {
    switch (this) {
      case BillType.electricity: return '⚡';
      case BillType.gas: return '🔥';
      case BillType.internet: return '🌐';
      case BillType.rent: return '🏠';
      case BillType.other: return '📋';
    }
  }
}

class BillModel {
  final String id;
  final BillType type;
  final String name;
  final double amount;
  final DateTime dueDate;
  bool isPaid;

  BillModel({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
  });

  BillStatus get status {
    if (isPaid) return BillStatus.paid;
    if (dueDate.isBefore(DateTime.now())) return BillStatus.late;
    return BillStatus.pending;
  }

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'name': name,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'isPaid': isPaid,
  };

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
    id: json['id'] as String,
    type: BillType.values[json['type'] as int],
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    dueDate: DateTime.parse(json['dueDate'] as String),
    isPaid: json['isPaid'] as bool? ?? false,
  );

  BillModel copyWith({bool? isPaid}) => BillModel(
    id: id, type: type, name: name, amount: amount, dueDate: dueDate,
    isPaid: isPaid ?? this.isPaid,
  );
}