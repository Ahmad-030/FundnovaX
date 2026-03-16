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
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return BillStatus.late;
    return BillStatus.pending;
  }

  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  BillModel copyWith({bool? isPaid}) {
    return BillModel(
      id: id,
      type: type,
      name: name,
      amount: amount,
      dueDate: dueDate,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
