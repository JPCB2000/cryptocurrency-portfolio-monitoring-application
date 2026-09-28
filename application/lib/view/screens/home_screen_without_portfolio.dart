import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:crypto_portfolio/constants/app_colors.dart';
import 'package:crypto_portfolio/constants/font_styles.dart';
import 'package:crypto_portfolio/helpers/cryptocurrency_helper.dart';
import 'package:crypto_portfolio/helpers/database_helper.dart';
import 'package:crypto_portfolio/models/cryptocurrency.dart';
import 'package:crypto_portfolio/utils/csv_utils.dart';
import 'package:crypto_portfolio/view/screens/home_screen_with_portfolio.dart';

class HomeScreenWithoutPortfolio extends StatefulWidget {
  const HomeScreenWithoutPortfolio({super.key});

  @override
  State<HomeScreenWithoutPortfolio> createState() => _HomeScreenWithoutPortfolioState();
}

class _HomeScreenWithoutPortfolioState extends State<HomeScreenWithoutPortfolio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.mainBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:40, right: 40),
                child: Text(
                  "Hi! Before using the application, choose one of the options below:",
                  style: FontStyles.montserratStyle(18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () async {
                  CsvUtils csvUtils = CsvUtils();
                  var csvResult = await csvUtils.selectCsvFile();
                  if (csvResult != null) {
                    List<Cryptocurrency> Cryptocurrencies = csvUtils.parseCSVIntoCryptocurrencyList(csvResult['fileName'], csvResult['csvString']);
                    final dbHelper = DatabaseHelper.instance;
                    final database = await dbHelper.database;
                    CryptocurrencyHelper cryptocurrencyHelper = CryptocurrencyHelper(database);
                    for (Cryptocurrency cryptocurrency in Cryptocurrencies) {
                      await cryptocurrencyHelper.insertCryptocurrency(cryptocurrency);
                    }
                    await dbHelper.copyDatabaseFileToExternalStorage();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeScreenWithPortfolio()));
                  } else {
                    final log = Logger();
                    log.i('No file selected.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryBackgroundColor,
                  maximumSize: const Size(300, double.infinity),
                  minimumSize: const Size(300, 70), 
                ),
                child: Text(
                  "Import a new portfolio .CSV file",
                  style: FontStyles.montserratStyle(15, color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryBackgroundColor, 
                  maximumSize: const Size(300, double.infinity),
                  minimumSize: const Size(300, 70),
                ),
                child: Text(
                  "Start with an empty portfolio",
                  style: FontStyles.montserratStyle(15, color: Colors.white),
                ),
              )
            ],
          ),
        ));
  }
}
