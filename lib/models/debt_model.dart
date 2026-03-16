enum DebtType { lent, borrowed }

class PaymentEntry {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  PaymentEntry({required this.id, required this.amount, required this.date, this.note});
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

  DebtModel copyWith({List<PaymentEntry>? payments}) {
    return DebtModel(
      id: id,
      type: type,
      contactName: contactName,
      totalAmount: totalAmount,
      dueDate: dueDate,
      note: note,
      payments: payments ?? this.payments,
    );
  }
}
