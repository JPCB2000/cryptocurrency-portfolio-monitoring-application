import 'package:sqflite/sqflite.dart';
import 'package:crypto_portfolio/helpers/coins_list_helper.dart';
import 'package:crypto_portfolio/models/alert.dart';
import 'package:crypto_portfolio/models/cryptocurrency.dart';

class AlertHelper {
  final Database _db;

  AlertHelper(this._db);

  Future<void> insertAlert(Alert alert) async {
    if (!CoinsListHelper().checkIfCoinExistsBySymbol(alert.symbol.toLowerCase())) {
      return;
    }
    await _db.insert('Alerts', alert.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
   Future<List<Alert>> getAllAlerts() async {
    final List<Map<String, dynamic>> maps = await _db.query('Alerts');

    return List.generate(maps.length, (index) {
      return Alert.fromMap(maps[index]);
    });
  }

  Future<void> deleteAlert(Alert alert) async {
    await _db.delete(
      'Alerts',
      where: 'Symbol = ? AND TargetPrice = ?',
      whereArgs: [alert.symbol, alert.targetPrice],
    );
  }

}
