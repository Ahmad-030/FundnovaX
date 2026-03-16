enum DebtType { lent, borrowed }

class PaymentEntry {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  PaymentEntry({required this.id, required this.amount, required this.date, this.note});

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory PaymentEntry.fromJson(Map<String, dynamic> json) => PaymentEntry(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    note: json['note'] as String?,
  );
}

class DebtModel {
  final String id;
  final DebtType type;
  final String contactName;
  final double totalAmount;
  final DateTime dueDate;
  final String? note;
  final List<PaymentEntry> payments;

  DebtModel({
    required this.id,
    required this.type,
    required this.contactName,
    required this.totalAmount,
    required this.dueDate,
    this.note,
    List<PaymentEntry>? payments,
  }) : payments = payments ?? [];

  double get paidAmount => payments.fold(0, (s, p) => s + p.amount);
  double get remainingAmount => (totalAmount - paidAmount).clamp(0, double.infinity);
  double get progressPercent => totalAmount > 0 ? (paidAmount / totalAmount).clamp(0, 1) : 0;
  bool get isSettled => remainingAmount <= 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'contactName': contactName,
    'totalAmount': totalAmount,
    'dueDate': dueDate.toIso8601String(),
    'note': note,
    'payments': payments.map((p) => p.toJson()).toList(),
  };

  factory DebtModel.fromJson(Map<String, dynamic> json) => DebtModel(
    id: json['id'] as String,
    type: DebtType.values[json['type'] as int],
    contactName: json['contactName'] as String,
    totalAmount: (json['totalAmount'] as num).toDouble(),
    dueDate: DateTime.parse(json['dueDate'] as String),
    note: json['note'] as String?,
    payments: (json['payments'] as List? ?? [])
        .map((p) => PaymentEntry.fromJson(p as Map<String, dynamic>))
        .toList(),
  );

  DebtModel copyWith({List<PaymentEntry>? payments}) => DebtModel(
    id: id, type: type, contactName: contactName,
    totalAmount: totalAmount, dueDate: dueDate, note: note,
    payments: payments ?? this.payments,
  );
}