import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CoinsListHelper {
  static final _log = Logger();
  static List<dynamic> coinsList = [];
  static List<String> symbolsList = [];

  CoinsListHelper() {
    fetchAndSaveCoinsList();
    _loadCoinsList();
  }

  void _loadCoinsList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/coins_list.json');

      // Check whether the file exists
      if (file.existsSync()) {
        String content = await file.readAsString();
        coinsList = json.decode(content);
        _log.i('Coin list loaded.');
      } else {
        _log.i('Coin list file not found.');
      }
    } catch (e) {
      _log.e('Error loading the coin list: $e');
    }
  }

  // Fetches the coin list from the CoinGecko API and stores it in coinsList
  Future<void> fetchCoinsList() async {
    final response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false&locale=en'));
    if (response.statusCode == 200) {
      _log.i('Coin list request completed.');
      coinsList = json.decode(response.body);
    } else {
      _log.i('Coin list request failed.');
    }
  }

  // Saves the data returned by the request to a local .json file
  Future<void> saveCoinsListToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/coins_list.json');
    await file.writeAsString(json.encode(coinsList));
  }

  // Fetches the coin list and saves it to a file (calls the two methods above)
  Future<void> fetchAndSaveCoinsList() async {
    await fetchCoinsList();
    await saveCoinsListToFile();
  }

  void extractSymbolsFromAvailableCryptocurrencies(List<dynamic> coinsList) {
    for (var coin in coinsList) {
      if (coin.containsKey("symbol")) {
        String symbol = coin["symbol"];
        symbolsList.add(symbol);
      }
    }
  }

  // Returns the id for a cryptocurrency symbol
  bool checkIfCoinExistsBySymbol(String symbol) {
    if (coinsList.isEmpty) {
      _log.e('The coin list has not been loaded yet.');
      return false;
    }

    for (var coin in coinsList) {
      if (coin['symbol'] == symbol) {
        return true;
      }
    }

    _log.i('No cryptocurrency found with symbol: $symbol');
    return false;
  }

  // Returns the id for a cryptocurrency symbol
  String? getCoinIdBySymbol(String symbol) {
    if (coinsList.isEmpty) {
      _log.e('The coin list has not been loaded yet.');
      return null;
    }

    for (var coin in coinsList) {
      if (coin['symbol'] == symbol) {
        return coin['id'];
      }
    }

    _log.i('No cryptocurrency found with symbol: $symbol');
    return null;
  }

  // Returns the name for a cryptocurrency symbol
  String? getCoinNameBySymbol(String symbol) {
    if (coinsList.isEmpty) {
      _log.e('The coin list has not been loaded yet.');
      return null;
    }

    for (var coin in coinsList) {
      if (coin['symbol'] == symbol) {
        return coin['name'];
      }
    }

    _log.i('No cryptocurrency found with symbol: $symbol');
    return null;
  }

  // Returns the image for a cryptocurrency symbol
  String? getCoinImageBySymbol(String symbol) {
    if (coinsList.isEmpty) {
      _log.e('The coin list has not been loaded yet.');
      return null;
    }

    for (var coin in coinsList) {
      if (coin['symbol'] == symbol) {
        return coin['image'];
      }
    }

    _log.i('No cryptocurrency found with symbol: $symbol');
    return null;
  }

  // Returns the current price for a cryptocurrency symbol
  String? getCoinPriceBySymbol(String symbol) {
    if (coinsList.isEmpty) {
      _log.e('The coin list has not been loaded yet.');
      return null;
    }

    for (var coin in coinsList) {
      if (coin['symbol'] == symbol) {
        double currentPrice = coin['current_price'].toDouble();
        String formattedPrice = currentPrice.toStringAsFixed(4); // Round to four decimal places
        return formattedPrice;
      }
    }

    _log.i('No cryptocurrency found with symbol: $symbol');
    return null;
  }

    String? getCoinMarketCapBySymbol(String symbol) {
    if (coinsList.isEmpty) {
      _log.e('The coin list has not been loaded yet.');
      return null;
    }

    for (var coin in coinsList) {
      if (coin['symbol'] == symbol) {
        return coin['market_cap'].toString();
      }
    }

    _log.i('No cryptocurrency found with symbol: $symbol');
    return null;
  }

  String? getCoinPriceVariationPercentageLastDayBySymbol(String symbol) {
    if (coinsList.isEmpty) {
      _log.e('The coin list has not been loaded yet.');
      return null;
    }

    for (var coin in coinsList) {
      if (coin['symbol'] == symbol) {
        double priceVariation = coin['price_change_percentage_24h'];
        String formattedPriceVariation = priceVariation.toStringAsFixed(2);
        return formattedPriceVariation;
      }
    }

    _log.i('No cryptocurrency found with symbol: $symbol');
    return null;
  }

  // Copies coins_list.json from the device's internal storage to external storage
  Future<void> copyCoinsListFileToExternalStorage() async {
    final directory = await getApplicationDocumentsDirectory();
    final sourceFile = File('${directory.path}/coins_list.json');
    final destinationFile = File('/sdcard/Documents/coins_list.json');
    try {
      await sourceFile.copy(destinationFile.path);
      _log.i('Coin list copied to external storage.');
    } catch (e) {
      _log.e('Error copying the coin list: $e');
    }
  }
}
