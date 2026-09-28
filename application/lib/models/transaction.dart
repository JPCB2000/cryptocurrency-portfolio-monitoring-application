class Transaction {
  String id;
  String blockId;
  var date;
  String status;
  var numEvents;
  Map<String, dynamic> meta;
  var blockNumber;
  var confirmations;
  List<Event> events;
  

  Transaction({
    required this.id,
    required this.blockId,
    required this.date,
    required this.status,
    required this.numEvents,
    required this.meta,
    required this.blockNumber,
    required this.confirmations,
    required this.events,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      blockId: json['block_id'],
      date: json['date'],
      status: json['status'],
      numEvents: json['num_events'],
      meta: json['meta'],
      blockNumber: json['block_number'],
      confirmations: json['confirmations'],
      events: List<Event>.from(json['events'].map((event) => Event.fromJson(event))),
    );
  }
}

class Event {
  String id;
  String transactionId;
  String type;
  String denomination;
  Map<String, dynamic>? meta;
  var date;
  var amount;
  var decimals;

  Event({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.denomination,
    required this.meta,
    required this.date,
    required this.amount,
    required this.decimals,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      transactionId: json['transaction_id'],
      type: json['type'],
      denomination: json['denomination'],
      meta: json['meta'],
      date: json['date'],
      amount: json['amount'],
      decimals: json['decimals'],
    );
  }
}
