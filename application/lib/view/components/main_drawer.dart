import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:crypto_portfolio/constants/app_colors.dart';
import 'package:crypto_portfolio/constants/font_styles.dart';
import 'package:crypto_portfolio/helpers/cryptocurrency_helper.dart';
import 'package:crypto_portfolio/helpers/database_helper.dart';
import 'package:crypto_portfolio/models/cryptocurrency.dart';
import 'package:crypto_portfolio/utils/csv_utils.dart';

class MainDrawer extends StatelessWidget {
  final Function? loadedDropdownState;

  const MainDrawer({super.key, 
    this.loadedDropdownState,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.mainBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height*0.1205,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBackgroundColor,
                ),
                child: Text(
                  'Actions',
                  style: FontStyles.montserratStyle(15, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Add new portfolio from files',
                style: FontStyles.montserratStyle(15),
              ),
              onTap: () async {
                CsvUtils csvUtils = CsvUtils();
                var csvResult = await csvUtils.selectCsvFile();
                if (csvResult != null) {
                  List<Cryptocurrency> cryptocurrencies = csvUtils.parseCSVIntoCryptocurrencyList(
                    csvResult['fileName'],
                    csvResult['csvString'],
                  );
                  final dbHelper = DatabaseHelper.instance;
                  final database = await dbHelper.database;
                  CryptocurrencyHelper cryptocurrencyHelper = CryptocurrencyHelper(database);
                  for (Cryptocurrency cryptocurrency in cryptocurrencies) {
                    await cryptocurrencyHelper.insertCryptocurrency(cryptocurrency);
                  }
                  loadedDropdownState!();
                  await dbHelper.copyDatabaseFileToExternalStorage();
                } else {
                  final log = Logger();
                  log.i('No file selected.');
                }
              },
            ),
            ListTile(
              title: Text(
                'Add new empty .CSV portfolio file',
                style: FontStyles.montserratStyle(15),
              ),
              onTap: () async {
                // TODO: add an empty portfolio
              },
            ),
            ListTile(
              title: Text(
                'View settings',
                style: FontStyles.montserratStyle(15),
              ),
              onTap: () async {
                // Your implementation for viewing settings
              },
            ),
            ListTile(
              title: Text(
                'Help',
                style: FontStyles.montserratStyle(15),
              ),
              onTap: () async {
                // Your implementation for help
              },
            ),
          ],
        ),
      ),
    );
  }
}
