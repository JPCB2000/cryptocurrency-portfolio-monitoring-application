import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:crypto_portfolio/models/transaction.dart';

class BlockchainHelper {
  static final _log = Logger();
  static List<dynamic> coinsList = [];
  static List<String> symbolsList = [];

  BlockchainHelper() {}

  // Blockdaemon API key, provided at build time:
  // flutter run --dart-define=BLOCKDAEMON_API_KEY=your_key
  static const _apiKey = String.fromEnvironment('BLOCKDAEMON_API_KEY');

// Fetches the on-chain transaction history of a wallet address through the Blockdaemon Universal API
Future<List<Transaction>> fetchTransactionsForAddress(String address, {String protocol = "ethereum", String network = "mainnet"}) async {
  final url = 'https://svc.blockdaemon.com/universal/v1/$protocol/$network/account/$address/txs';
  final apiKey = _apiKey;

  if (apiKey.isEmpty) {
    _log.e('Missing BLOCKDAEMON_API_KEY. Run with --dart-define=BLOCKDAEMON_API_KEY=your_key');
    return [];
  }

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-API-Key': apiKey,
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Decode the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Check if 'data' key is present and is a list
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List<dynamic>) {
        // Create a list of Transaction objects
        List<Transaction> transactions = (jsonResponse['data'] as List<dynamic>).map((data) => Transaction.fromJson(data)).toList();
        return transactions;
      } else {
        // Handle the case where 'data' key is not present or not a list
        print('Error: "data" key is missing or is not a list');
        return [];
      }
    } else {
      // Handle the case where the response was not successful
      print('Request failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return []; // Return an empty list in case of an error
    }
  } catch (e) {
    // Handle exceptions during the request
    print('Error during request: $e');
    return []; // Return an empty list in case of an exception
  }
}


}
