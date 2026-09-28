class Alert {
  final String symbol; // Cryptocurrency symbol (e.g. btc)
  final double targetPrice; // Price that triggers the alert
  bool Status; // Whether the alert has been resolved

  Alert({
    required this.symbol,
    required this.targetPrice,
    this.Status = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'Symbol': symbol,
      'TargetPrice': targetPrice,
      'Status': Status == 1,
    };
    return map;
  }

  Alert.fromMap(Map<String, dynamic> map)
    : symbol = map['Symbol'],
      targetPrice = map['TargetPrice'],
      Status = map['Status'] == 1; // Convert to a boolean
}
