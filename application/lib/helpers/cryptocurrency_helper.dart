import 'package:sqflite/sqflite.dart';
import 'package:crypto_portfolio/helpers/coins_list_helper.dart';
import 'package:crypto_portfolio/models/cryptocurrency.dart';

class CryptocurrencyHelper {
  final Database _db;

  CryptocurrencyHelper(this._db);

  // Inserts a Cryptocurrency into the portfolio. If the coin is already in that portfolio, the values are averaged before it is added
  Future<void> insertCryptocurrency(Cryptocurrency cryptocurrency) async {
    // Do nothing if the cryptocurrency is not in the list of available coins
    if (!CoinsListHelper().checkIfCoinExistsBySymbol(cryptocurrency.symbol.toLowerCase())) {
      return;
    }

    final existingCrypto = await getCryptocurrencyInPortfolio(cryptocurrency.portfolio, cryptocurrency.symbol);

    if (existingCrypto != null) {
      // Update the values of the existing record
      final newQuantity = existingCrypto.quantity + cryptocurrency.quantity;
      final newAveragePurchasePrice = (cryptocurrency.averagePurchasePrice != 0)
          ? (existingCrypto.averagePurchasePrice * existingCrypto.quantity + cryptocurrency.averagePurchasePrice * cryptocurrency.quantity) /
              newQuantity
          : existingCrypto.averagePurchasePrice;
      final updatedCrypto = Cryptocurrency(
        portfolio: cryptocurrency.portfolio,
        symbol: cryptocurrency.symbol.toUpperCase(),
        quantity: newQuantity,
        averagePurchasePrice: newAveragePurchasePrice,
      );

      // Update the existing record in the database
      await updateCryptocurrency(updatedCrypto);
    } else {
      // If the coin does not exist yet, insert it
      await _db.insert('Cryptocurrencies', cryptocurrency.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Returns a Cryptocurrency from a portfolio, given the portfolio name and the coin symbol
  Future<Cryptocurrency?> getCryptocurrencyInPortfolio(String portfolio, String symbol) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'Cryptocurrencies',
      where: 'Portfolio = ? AND Symbol = ?',
      whereArgs: [portfolio, symbol],
    );

    if (maps.isNotEmpty) {
      return Cryptocurrency.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Returns every Cryptocurrency in the given portfolio
  Future<List<Cryptocurrency>> getCryptocurrenciesFromPortfolio(String portfolioName) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'Cryptocurrencies',
      where: 'Portfolio = ?',
      whereArgs: [portfolioName],
    );

    final cryptocurrencies = List.generate(maps.length, (i) {
      return Cryptocurrency.fromMap(maps[i]);
    });

    return cryptocurrencies;
  }

  // Returns every Cryptocurrency stored in the database
  Future<List<Cryptocurrency>> getAllCryptocurrencies() async {
    final List<Map<String, dynamic>> maps = await _db.query('Cryptocurrencies');

    return List.generate(maps.length, (i) {
      return Cryptocurrency.fromMap(maps[i]);
    });
  }

  // Updates the quantity and/or average purchase price of a Cryptocurrency
  Future<void> updateCryptocurrency(Cryptocurrency cryptocurrency) async {
    await _db.update(
      'Cryptocurrencies',
      cryptocurrency.toMap(),
      where: 'Symbol = ? AND Portfolio = ?',
      whereArgs: [cryptocurrency.symbol, cryptocurrency.portfolio],
    );
  }

  // Deletes an entire portfolio by name
  Future<void> deleteCryptocurrencyPortfolio(String portfolio) async {
    final rowsAffected = await _db.delete(
      'Cryptocurrencies',
      where: 'Portfolio = ?',
      whereArgs: [portfolio],
    );

    if (rowsAffected > 0) {
      print('Deleted $rowsAffected records.');
    } else {
      print('No records found to delete.');
    }
  }

  // Deletes a Cryptocurrency from a portfolio, given the coin symbol and portfolio name
  Future<void> deleteCryptocurrencyInPortfolio(String portfolio, String symbol) async {
    final rowsAffected = await _db.delete(
      'Cryptocurrencies',
      where: 'Symbol = ? AND Portfolio = ?',
      whereArgs: [symbol, portfolio],
    );

    if (rowsAffected > 0) {
      print('Deleted $rowsAffected records.');
    } else {
      print('No records found to delete.');
    }
  }

  // Deletes every Cryptocurrency stored in the database
  Future<void> deleteAllCryptocurrencies() async {
    try {
      final rowsAffected = await _db.delete('Cryptocurrencies');
      print('Deleted $rowsAffected records.');
    } catch (e) {
      print('Error deleting records: $e');
    }
  }

  // Returns true if a portfolio with the given name exists
  Future<bool> checkIfPortfolioExists(String portfolioName) async {
    final count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM Cryptocurrencies WHERE Portfolio = ?', [portfolioName]));
    return count != null && count > 0;
  }

  // Returns the number of distinct portfolios in the database
  Future<int> countDistinctPortfolios() async {
    final result = await _db.rawQuery('SELECT COUNT(DISTINCT Portfolio) FROM Cryptocurrencies');
    final count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }

  // Returns all portfolio names, ordered by number of cryptocurrencies (descending)
  Future<List<String>> getPortfoliosOrderedByCryptocurrencies() async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT Portfolio, COUNT(Symbol) AS CryptoCount
      FROM Cryptocurrencies
      GROUP BY Portfolio
      ORDER BY CryptoCount DESC
    ''');

    final portfolios = List.generate(maps.length, (i) {
      return maps[i]['Portfolio'] as String;
    });

    return portfolios;
  }
}
