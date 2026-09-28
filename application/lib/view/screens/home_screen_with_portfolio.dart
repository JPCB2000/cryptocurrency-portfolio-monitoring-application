import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:crypto_portfolio/constants/app_colors.dart';
import 'package:crypto_portfolio/constants/font_styles.dart';
import 'package:crypto_portfolio/helpers/coins_list_helper.dart';
import 'package:crypto_portfolio/helpers/cryptocurrency_helper.dart';
import 'package:crypto_portfolio/helpers/database_helper.dart';
import 'package:crypto_portfolio/models/cryptocurrency.dart';
import 'package:crypto_portfolio/view/components/main_bottom_navigation_bar.dart';
import 'package:crypto_portfolio/view/components/main_drawer.dart';
import 'package:crypto_portfolio/view/components/portfolio_dropdown.dart';
import 'package:crypto_portfolio/view/screens/alert_screen.dart';
import 'package:crypto_portfolio/view/screens/home_screen_without_portfolio.dart';

class HomeScreenWithPortfolio extends StatefulWidget {
  const HomeScreenWithPortfolio({Key? key}) : super(key: key);

  @override
  _HomeScreenWithPortfolioState createState() => _HomeScreenWithPortfolioState();
}

class _HomeScreenWithPortfolioState extends State<HomeScreenWithPortfolio> {
  int _currentIndex = 0;
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  CoinsListHelper coinsListHelper = CoinsListHelper();
  
  List<String> portfolios = [];
  String? selectedPortfolio;
  List<Cryptocurrency> cryptocurrencies = [];
  var dbHelper;
  var database;
  var cryptocurrencyHelper;

  Future<void> loadData() async {
    dbHelper = DatabaseHelper.instance;
    database = await dbHelper.database;
    cryptocurrencyHelper = await CryptocurrencyHelper(database);

    List<String> allPortfoliosOrderedByCryptocurrencyCount = await cryptocurrencyHelper.getPortfoliosOrderedByCryptocurrencies();

    setState(() {
      portfolios = allPortfoliosOrderedByCryptocurrencyCount;

      // Default to the first item in the list
      selectedPortfolio = portfolios.isNotEmpty ? portfolios[0] : '';
    });
    await getCryptocurrenciesFromPortfolioToShow(selectedPortfolio!);
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Portfolios',
          style: FontStyles.montserratStyle(18),
        ),
        backgroundColor: AppColors.secondaryBackgroundColor,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white,),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: MainDrawer(
        loadedDropdownState: () {
          loadData();
        },
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PortfolioDropdown(
                  portfolios: portfolios,
                  selectedPortfolio: selectedPortfolio,
                  getCryptocurrenciesCallback: updateCryptocurrencies,
                ),
                Tooltip(
                  message: 'Refresh this page',
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.125,
                    height: MediaQuery.of(context).size.height * 0.0625,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.blueAccent,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: () {
                        coinsListHelper.fetchAndSaveCoinsList();
                        setState(() {});
                      },
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Add new token to this portfolio',
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.125,
                    height: MediaQuery.of(context).size.height * 0.0625,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.green,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      color: Colors.white,
                      onPressed: () {
                        addNewCurrencyDialog();
                      },
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Delete this portfolio',
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.125,
                    height: MediaQuery.of(context).size.height * 0.0625,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.redAccent,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: AppColors.secondaryBackgroundColor,
                                title: Text(
                                  'Confirm portfolio deletion',
                                  style: FontStyles.montserratStyle(20),
                                ),
                                content: Text('Are you sure you want to delete your "${selectedPortfolio}" portfolio?',
                                    style: FontStyles.montserratStyle(15)),
                                actions: [
                                  // Cancel button
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel', style: FontStyles.montserratStyle(15)),
                                  ),
                                  // Confirm deletion button
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      deleteCurrentPortfolio(selectedPortfolio!);
                                    },
                                    child: Text('Confirm', style: FontStyles.montserratStyle(15)),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cryptocurrencies.length,
                      itemBuilder: (context, index) {
                        String symbolLowerCase = cryptocurrencies[index].symbol.toLowerCase();
                        String? coinCurrentPrice = coinsListHelper.getCoinPriceBySymbol(symbolLowerCase);
                        String? coinImage = coinsListHelper.getCoinImageBySymbol(symbolLowerCase);
                        String currentPortfolioValueForCoin = (double.parse(coinCurrentPrice!) * cryptocurrencies[index].quantity).toStringAsFixed(4);
                        return GestureDetector(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(
                                        coinImage!,
                                        width: MediaQuery.of(context).size.width * 0.1,
                                        height: MediaQuery.of(context).size.width * 0.1,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cryptocurrencies[index].symbol,
                                          style: FontStyles.montserratStyle(22),
                                        ),
                                        Text(
                                          cryptocurrencies[index].quantity.toStringAsFixed(2),
                                          style: FontStyles.montserratStyle(14, color: AppColors.selectedItemColor),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Text(
                                      'U\$ $currentPortfolioValueForCoin',
                                      style: FontStyles.montserratStyle(22),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            changeSelectedCurrencyDialog(index, cryptocurrencies[index].quantity.toString(),
                                cryptocurrencies[index].averagePurchasePrice.toString(), currentPortfolioValueForCoin, symbolLowerCase);
                          },
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNavigationBar(
        currentIndex: _currentIndex,
      ),
    );
  }

  void addNewCurrencyDialog() {
    controller1.text = "";
    controller2.text = "";
    controller3.text = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            color: AppColors.mainBackgroundColor,
            height: MediaQuery.of(context).size.height * 0.55,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Add new token',
                    style: FontStyles.montserratStyle(18, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                TextField(
                  controller: controller1,
                  style: FontStyles.montserratStyle(15, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Symbol',
                    labelStyle: FontStyles.montserratStyle(15, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                TextField(
                  controller: controller2,
                  style: FontStyles.montserratStyle(15, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: FontStyles.montserratStyle(15, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                TextField(
                  controller: controller3,
                  style: FontStyles.montserratStyle(15, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Average purchase price',
                    labelStyle: FontStyles.montserratStyle(15, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.0625),
                ElevatedButton(
                  onPressed: () async {
                    Cryptocurrency cryptocurrencyToInsert = Cryptocurrency(
                        portfolio: selectedPortfolio!,
                        symbol: controller1.text.toString(),
                        quantity: double.parse(controller2.text.toString()),
                        averagePurchasePrice: double.parse(controller3.text.toString()));
                    await cryptocurrencyHelper.insertCryptocurrency(cryptocurrencyToInsert);
                    setState(() {
                      getCryptocurrenciesFromPortfolioToShow(selectedPortfolio!);
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBackgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Confirm",
                    style: FontStyles.montserratStyle(15, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void changeSelectedCurrencyDialog(
      int index, String ownedAmount, String averagePurchasePrice, String currentPortfolioValueForCoin, String symbolLowerCase) {
    String? coinImage;
    String? coinName;
    String? coinPrice;
    String? priceVariation;
    String? coinMarketCap;
    String symbolUpperCase = symbolLowerCase.toUpperCase();
    MaterialColor priceVariationColor;
    coinImage = coinsListHelper.getCoinImageBySymbol(symbolLowerCase);
    coinName = coinsListHelper.getCoinNameBySymbol(symbolLowerCase);
    coinPrice = coinsListHelper.getCoinPriceBySymbol(symbolLowerCase);
    coinMarketCap = coinsListHelper.getCoinMarketCapBySymbol(symbolLowerCase);
    priceVariation = coinsListHelper.getCoinPriceVariationPercentageLastDayBySymbol(symbolLowerCase);

    double.parse(priceVariation!) >= 0 ? priceVariationColor = Colors.green : priceVariationColor = Colors.red;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            child: SingleChildScrollView(
          child: Container(
              color: AppColors.mainBackgroundColor,
              height: MediaQuery.of(context).size.height * 0.55,
              width: MediaQuery.of(context).size.width * 1,
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Image.network(
                            coinImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.0125),
                          Text(
                            "$coinName ($symbolUpperCase)",
                            style: FontStyles.montserratStyle(20),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                    Row(
                      children: [
                        Text(
                          "Owned amount:",
                          style: FontStyles.montserratStyle(14),
                        ),
                        Spacer(),
                        Text(
                          ownedAmount!,
                          style: FontStyles.montserratStyle(14),
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                    Row(
                      children: [
                        Text(
                          "Current price:",
                          style: FontStyles.montserratStyle(14),
                        ),
                        Spacer(),
                        Text(
                          "U\$ $coinPrice",
                          style: FontStyles.montserratStyle(14),
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                    Row(
                      children: [
                        Text(
                          "Average purchase price:",
                          style: FontStyles.montserratStyle(14),
                        ),
                        Spacer(),
                        Text(
                          "U\$ ${double.parse(averagePurchasePrice).toStringAsFixed(4)}",
                          style: FontStyles.montserratStyle(14),
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                    Row(
                      children: [
                        Text(
                          "Total portfolio value:",
                          style: FontStyles.montserratStyle(14),
                        ),
                        Spacer(),
                        Text(
                          "U\$ $currentPortfolioValueForCoin",
                          style: FontStyles.montserratStyle(14),
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                    Row(
                      children: [
                        Text(
                          "Market cap:",
                          style: FontStyles.montserratStyle(14),
                        ),
                        Spacer(),
                        Text(
                          "U\$ $coinMarketCap",
                          style: FontStyles.montserratStyle(14),
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                    Row(
                      children: [
                        Text(
                          "Price variation (24 hours):",
                          style: FontStyles.montserratStyle(14),
                        ),
                        Spacer(),
                        Text(
                          "$priceVariation %",
                          style: FontStyles.montserratStyle(14, color: priceVariationColor),
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.pop(context);
                            addCoinDialog(index, ownedAmount, averagePurchasePrice, currentPortfolioValueForCoin, symbolLowerCase);
                          },
                          iconSize: 30,
                          color: Colors.white,
                        ),

                        // Spacing between buttons
                        Spacer(),

                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            Navigator.pop(context);
                            dropCoinDialog(index, ownedAmount, averagePurchasePrice, currentPortfolioValueForCoin, symbolLowerCase);
                          },
                          iconSize: 30,
                          color: Colors.white,
                        ),

                        Spacer(),

                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: AppColors.secondaryBackgroundColor,
                                    title: Text(
                                      'Confirm $symbolUpperCase deletion',
                                      style: FontStyles.montserratStyle(20),
                                    ),
                                    content: Text('Are you sure you want to delete your "$symbolUpperCase" from this portfolio?',
                                        style: FontStyles.montserratStyle(14)),
                                    actions: [
                                      // Cancel button
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel', style: FontStyles.montserratStyle(15)),
                                      ),
                                      // Confirm deletion button
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          deleteCoinFromPortfolio(index);
                                        },
                                        child: Text('Confirm', style: FontStyles.montserratStyle(15)),
                                      ),
                                    ],
                                  );
                                });
                          },
                          iconSize: 30,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ));
      },
    );
  }

  void addCoinDialog(int index, String ownedAmount, String averagePurchasePrice, String currentPortfolioValueForCoin, String symbolLowerCase) {
    controller1.text = "";
    controller2.text = "";
    String symbolUpperCase = symbolLowerCase.toUpperCase();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            color: AppColors.mainBackgroundColor,
            height: MediaQuery.of(context).size.height * 0.375,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Add $symbolUpperCase to wallet',
                    style: FontStyles.montserratStyle(18, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                TextField(
                  controller: controller1,
                  style: FontStyles.montserratStyle(14, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: FontStyles.montserratStyle(14, color: Colors.white),
                  ),
                ),
                TextField(
                  controller: controller2,
                  style: FontStyles.montserratStyle(14, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Average Purchase Price',
                    labelStyle: FontStyles.montserratStyle(14, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                ElevatedButton(
                  onPressed: () async {
                    var cryptocurrencyToInsertAveragePrice = double.tryParse(controller2.text.toString());
                    Cryptocurrency cryptocurrencyToInsert;
                    if (cryptocurrencyToInsertAveragePrice != null) {
                      cryptocurrencyToInsert = Cryptocurrency(
                          portfolio: selectedPortfolio!,
                          symbol: symbolLowerCase.toUpperCase(),
                          quantity: double.parse(controller1.text.toString()),
                          averagePurchasePrice: cryptocurrencyToInsertAveragePrice);
                      await cryptocurrencyHelper.insertCryptocurrency(cryptocurrencyToInsert);
                    } else {
                      cryptocurrencyToInsert = Cryptocurrency(
                          portfolio: selectedPortfolio!,
                          symbol: symbolLowerCase.toUpperCase(),
                          quantity: double.parse(controller1.text.toString()),
                          averagePurchasePrice: 0);
                      await cryptocurrencyHelper.insertCryptocurrency(cryptocurrencyToInsert);
                    }
                    setState(() {
                      getCryptocurrenciesFromPortfolioToShow(selectedPortfolio!);
                    });
                    ownedAmount = (double.parse(ownedAmount) + cryptocurrencyToInsert.quantity).toString();
                    averagePurchasePrice = cryptocurrencies[index].averagePurchasePrice.toString();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBackgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Confirm",
                    style: FontStyles.montserratStyle(14, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void dropCoinDialog(int index, String ownedAmount, String averagePurchasePrice, String currentPortfolioValueForCoin, String symbolLowerCase) {
    controller1.text = "";
    String symbolUpperCase = symbolLowerCase.toUpperCase();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            color: AppColors.mainBackgroundColor,
            height: MediaQuery.of(context).size.height * 0.275,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Subtract $symbolUpperCase from wallet',
                    style: FontStyles.montserratStyle(18, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                TextField(
                  controller: controller1,
                  style: FontStyles.montserratStyle(14, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: FontStyles.montserratStyle(14, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                ElevatedButton(
                  onPressed: () async {
                    double amountToSubtract = double.parse(controller1.text.toString());
                    if (amountToSubtract >= double.parse(ownedAmount)) {
                      await cryptocurrencyHelper.deleteCryptocurrencyInPortfolio(symbolUpperCase, selectedPortfolio);
                    } else {
                      Cryptocurrency cryptocurrencyToInsert = Cryptocurrency(
                          portfolio: selectedPortfolio!,
                          symbol: symbolLowerCase.toUpperCase(),
                          quantity: double.parse(controller1.text.toString()) * -1,
                          averagePurchasePrice: 0);
                      await cryptocurrencyHelper.insertCryptocurrency(cryptocurrencyToInsert);
                    }
                    setState(() {
                      getCryptocurrenciesFromPortfolioToShow(selectedPortfolio!);
                    });
                    ownedAmount = (double.parse(ownedAmount) - amountToSubtract).toString();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBackgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Confirm",
                    style: FontStyles.montserratStyle(14, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void sortCryptocurrencyListByPortfolioValue(List<Cryptocurrency> cryptocurrencies) {
    for (int i = 0; i < cryptocurrencies.length - 1; i++) {
      for (int j = i + 1; j < cryptocurrencies.length; j++) {
        double priceI = double.parse(coinsListHelper.getCoinPriceBySymbol(cryptocurrencies[i].symbol.toLowerCase())!);
        double priceJ = double.parse(coinsListHelper.getCoinPriceBySymbol(cryptocurrencies[j].symbol.toLowerCase())!);

        if ((cryptocurrencies[i].quantity * priceI) < (cryptocurrencies[j].quantity * priceJ)) {
          // Swap the elements
          var temp = cryptocurrencies[i];
          cryptocurrencies[i] = cryptocurrencies[j];
          cryptocurrencies[j] = temp;
        }
      }
    }
  }

  Future<Cryptocurrency> getCoinData(String symbolUpperCase) async {
    return await cryptocurrencyHelper.getCryptocurrencyInPortfolio(selectedPortfolio, symbolUpperCase);
  }

  Future<void> getCryptocurrenciesFromPortfolioToShow(String portfolio) async {
    var cryptocurrenciesAux = await cryptocurrencyHelper.getCryptocurrenciesFromPortfolio(portfolio);
    sortCryptocurrencyListByPortfolioValue(cryptocurrenciesAux);
    setState(() {
      cryptocurrencies = cryptocurrenciesAux;
    });
  }

  void updateCryptocurrencies(String newPortfolio) {
    setState(() {
      selectedPortfolio = newPortfolio;
      getCryptocurrenciesFromPortfolioToShow(newPortfolio);
    });
  }

  Future<void> deleteCoinFromPortfolio(index) async {
    await cryptocurrencyHelper.deleteCryptocurrencyInPortfolio(cryptocurrencies[index].portfolio, cryptocurrencies[index].symbol);
    var cryptocurrenciesAfterDeletion = await cryptocurrencyHelper.getCryptocurrenciesFromPortfolio(cryptocurrencies[index].portfolio);
    setState(() {
      cryptocurrencies = cryptocurrenciesAfterDeletion;
    });
  }

  Future<void> deleteCurrentPortfolio(String portfolio) async {
    await cryptocurrencyHelper.deleteCryptocurrencyPortfolio(portfolio);
    var portfoliosAfterDeletion = await cryptocurrencyHelper.getPortfoliosOrderedByCryptocurrencies();

    setState(() {
      if (portfoliosAfterDeletion.isEmpty) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreenWithoutPortfolio()));
      } else {
        selectedPortfolio = portfoliosAfterDeletion[0];
        portfolios = portfoliosAfterDeletion;
        loadData();
      }
    });
  }
}
