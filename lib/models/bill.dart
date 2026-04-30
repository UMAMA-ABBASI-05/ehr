class Bill {
  final int billId;
  final double insuranceAmount;
  final bool billStatus;
  final DateTime billDate;

  Bill({
    required this.billId,
    required this.insuranceAmount,
    required this.billStatus,
    required this.billDate,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        billId: json['bill_id'],
        insuranceAmount: json['insurance_amount'].toDouble(),
        billStatus: json['bill_status'],
        billDate: DateTime.parse(json['bill_date']),
      );
}
