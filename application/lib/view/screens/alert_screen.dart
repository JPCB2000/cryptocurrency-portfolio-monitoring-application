import 'package:flutter/material.dart';
import 'package:crypto_portfolio/constants/app_colors.dart';
import 'package:crypto_portfolio/constants/font_styles.dart';
import 'package:crypto_portfolio/helpers/alert_helper.dart';
import 'package:crypto_portfolio/helpers/coins_list_helper.dart';
import 'package:crypto_portfolio/helpers/database_helper.dart';
import 'package:crypto_portfolio/models/alert.dart';
import 'package:crypto_portfolio/view/components/main_bottom_navigation_bar.dart';
import 'package:crypto_portfolio/view/screens/home_screen_with_portfolio.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({Key? key}) : super(key: key);

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  int _currentIndex = 1;
  List<Alert> alerts = [];
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  MaterialColor notificationIconColor = Colors.grey;
  var dbHelper;
  var database;
  var alertHelper;

  Future<void> loadData() async {
    notificationIconColor = Colors.grey;
    dbHelper = DatabaseHelper.instance;
    database = await dbHelper.database;
    alertHelper = await AlertHelper(database);

    setState(() {});
    await updateAlertListWithDatabase();
  }

  CoinsListHelper coinsListHelper = CoinsListHelper();

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackgroundColor,
        title: Text(
          'Alerts',
          style: FontStyles.montserratStyle(18),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              for (Alert alert in alerts) {
                if (alert.Status) {
                  await alertHelper.deleteAlert(alert);
                }
              }
              setState(() {
                notificationIconColor = Colors.grey;
              });
              await updateAlertListWithDatabase();
            },
            icon: Icon(
              Icons.notifications,
              color: notificationIconColor,
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.mainBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              MaterialColor currentAlertStatus;
              alerts[index].Status ? currentAlertStatus = Colors.green : currentAlertStatus = Colors.red;
              String symbolLowerCase = alerts[index].symbol.toLowerCase();
              String? coinCurrentPrice = coinsListHelper.getCoinPriceBySymbol(symbolLowerCase);
              String? coinImage = coinsListHelper.getCoinImageBySymbol(symbolLowerCase);
              return GestureDetector(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Row(
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
                                  alerts[index].symbol,
                                  style: FontStyles.montserratStyle(22, color: currentAlertStatus),
                                ),
                              ],
                            ),
                            Spacer(),
                            Text(
                              'U\$ ${alerts[index].targetPrice}',
                              style: FontStyles.montserratStyle(22),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  viewAlertDialog(index, alerts[index].targetPrice, coinImage, symbolLowerCase);
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNavigationBar(
        currentIndex: _currentIndex,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: () {
            addNewAlertDialog();
            // Add your functionality when the button is pressed
          },
          backgroundColor: AppColors.secondaryBackgroundColor,
          child: const Icon(Icons.add, color: Colors.white,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  void viewAlertDialog(int index, double targetPrice, String coinImage, String symbolLowerCase) {
    String? coinName;
    coinName = coinsListHelper.getCoinNameBySymbol(symbolLowerCase);
    String alertStatusText;
    MaterialColor alertStatusTextColor;
    alerts[index].Status ? alertStatusTextColor = Colors.green : alertStatusTextColor = Colors.red;
    alerts[index].Status ? alertStatusText = "Resolved" : alertStatusText = "Unresolved";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              color: AppColors.mainBackgroundColor,
              height: MediaQuery.of(context).size.height * 0.425,
              width: MediaQuery.of(context).size.width * 1,
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                          "$coinName (${symbolLowerCase.toUpperCase()})",
                          style: FontStyles.montserratStyle(20),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                  Row(
                    children: [
                      Text(
                        "Status:",
                        style: FontStyles.montserratStyle(16),
                      ),
                      Spacer(),
                      Text(
                        alertStatusText,
                        style: FontStyles.montserratStyle(16, color: alertStatusTextColor),
                      )
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                  Row(
                    children: [
                      Text(
                        "Target price:",
                        style: FontStyles.montserratStyle(16),
                      ),
                      Spacer(),
                      Text(
                        targetPrice.toString(),
                        style: FontStyles.montserratStyle(16),
                      )
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                  Row(
                    children: [
                      Text(
                        "Current price:",
                        style: FontStyles.montserratStyle(16),
                      ),
                      Spacer(),
                      Text(
                        coinsListHelper.getCoinPriceBySymbol(symbolLowerCase)!,
                        style: FontStyles.montserratStyle(16),
                      )
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                  ElevatedButton(
                    child: Text(
                      "Delete this alert",
                      style: FontStyles.montserratStyle(14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBackgroundColor,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.75, MediaQuery.of(context).size.height * 0.05),
                    ),
                    onPressed: () async {
                      await alertHelper.deleteAlert(alerts[index]);
                      updateAlertListWithDatabase();
                      Navigator.of(context).pop();
                    },
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  void addNewAlertDialog() {
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
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Center(
                    child: Text(
                      'Add new alert',
                      style: FontStyles.montserratStyle(18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                  TextField(
                    controller: controller1,
                    style: FontStyles.montserratStyle(15, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Coin symbol',
                      labelStyle: FontStyles.montserratStyle(15, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                  TextField(
                    controller: controller2,
                    style: FontStyles.montserratStyle(15, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Target price',
                      labelStyle: FontStyles.montserratStyle(15, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03650),
                  ElevatedButton(
                    child: Text(
                      "Confirm",
                      style: FontStyles.montserratStyle(14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBackgroundColor,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.75, MediaQuery.of(context).size.height * 0.05),
                    ),
                    onPressed: () async {
                      double? targetPriceAsDouble = double.tryParse(controller2.text.toString());
                      if (targetPriceAsDouble != null) {
                        Alert alertToInsert = Alert(
                          symbol: controller1.text.toString().toUpperCase(),
                          targetPrice: targetPriceAsDouble,
                          Status: false,
                        );
                        await alertHelper.insertAlert(alertToInsert);
                        updateAlertListWithDatabase();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ])));
      },
    );
  }

  Future<void> updateAlertListWithDatabase() async {
    List<Alert> auxAlertList = List.empty();
    auxAlertList = await alertHelper.getAllAlerts();
    bool foundNewAlert = false;
    setState(() {
      alerts = auxAlertList;
      for (Alert alert in alerts) {
        if (alert.targetPrice < double.tryParse(coinsListHelper.getCoinPriceBySymbol(alert.symbol.toLowerCase())!)!) {
          alert.Status = true;
          foundNewAlert = true;
        }
      }
      foundNewAlert ? notificationIconColor = Colors.yellow : Colors.grey;
    });
  }
}
