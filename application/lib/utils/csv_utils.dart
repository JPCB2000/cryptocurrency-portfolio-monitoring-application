import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto_portfolio/models/cryptocurrency.dart';

class CsvUtils {
  // Lets the user pick a .csv file and returns a map with the file name and its contents as a string
  Future<Map?> selectCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    ); // Opens the system file picker

    if (result != null) {
      final file = File(result.files.single.path!);
      final fileNameWithExtension = result.files.single.name;

      // The file name (without the .csv extension) becomes the portfolio name
      final fileName = fileNameWithExtension.replaceAll('.csv', '');

      final csvString = await file.readAsString();

      return {'fileName': fileName, 'csvString': csvString};
    } else {
      // No file selected
      print('No file selected');
      return null;
    }
  }

  void createEmptyCsvFile() {
    // TODO: create an empty CSV file
    print('Create an empty CSV file');
  }

  // Parses the contents of an imported .csv file into Cryptocurrency objects for the given portfolio
  List<Cryptocurrency> parseCSVIntoCryptocurrencyList(String portfolioName, String csvString) {
    final List<List<dynamic>> csvList = const CsvToListConverter(eol: '\n', fieldDelimiter: ';').convert(csvString);
    final List<Cryptocurrency> processedCryptocurrencies = [];
    for (final row in csvList) {
      if (row.isNotEmpty) {
        final cryptocurrency = Cryptocurrency(
          portfolio: portfolioName,
          symbol: row[0],
          quantity: double.tryParse(row[1].toString()) ?? 0.0,
          averagePurchasePrice: double.tryParse(row[2].toString()) ?? 0.0,
        );
        processedCryptocurrencies.add(cryptocurrency);
      }
    }
    return processedCryptocurrencies;
  }
}
