class Cryptocurrency {
  final String portfolio; // Portfolio name
  final String symbol; // Cryptocurrency symbol (e.g. btc)
  final double quantity; // Amount of the cryptocurrency held
  final double averagePurchasePrice; // Average purchase price

  Cryptocurrency({
    required this.portfolio,
    required this.symbol,
    required this.quantity,
    required this.averagePurchasePrice,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'Portfolio': portfolio, 
      'Symbol': symbol,
      'Quantity': quantity,
      'AveragePurchasePrice': averagePurchasePrice,
    };
    return map;
  }

  Cryptocurrency.fromMap(Map<String, dynamic> map)
      : portfolio = map['Portfolio'],
        symbol = map['Symbol'],
        quantity = map['Quantity'],
        averagePurchasePrice = map['AveragePurchasePrice'];
}
