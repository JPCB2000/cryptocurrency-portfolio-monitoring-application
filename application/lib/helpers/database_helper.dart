import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  // Database file name
  static const _databaseName = 'cryptocurrency_database.db';
  static final _log = Logger();

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Cryptocurrencies(
        Portfolio TEXT,
        Symbol TEXT,
        Quantity REAL,
        AveragePurchasePrice REAL
      )
    ''');
    _log.i('Cryptocurrencies table created.');

    await db.execute('''
      CREATE TABLE Alerts(
        Symbol TEXT,
        TargetPrice REAL,
        Status BOOLEAN
      )
    ''');
    _log.i('Alerts table created.');
  }

  Future<void> copyDatabaseFileToExternalStorage() async {
    final appDocDir = await getDatabasesPath();
    final sourceFile = File('$appDocDir/$_databaseName');
    final destinationFile = File('/sdcard/Documents/$_databaseName');

    try {
      await sourceFile.copy(destinationFile.path);
      _log.i('Database copied to external storage.');
    } catch (e) {
      _log.e('Error copying the database: $e');
    }
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _log.i('Database deleted.');
      }
    } catch (e) {
      _log.e('Error deleting the database: $e');
    }
  }
}
