import 'package:flutter/material.dart';
import 'package:crypto_portfolio/constants/app_colors.dart';
import 'package:crypto_portfolio/constants/font_styles.dart';
import 'package:crypto_portfolio/helpers/blockchain_helper.dart';
import 'package:crypto_portfolio/models/transaction.dart';
import 'package:crypto_portfolio/view/components/main_bottom_navigation_bar.dart';

class BlockchainDataScreen extends StatefulWidget {
  const BlockchainDataScreen({super.key});

  @override
  State<BlockchainDataScreen> createState() => _BlockchainDataScreenState();
}

class _BlockchainDataScreenState extends State<BlockchainDataScreen> {
  int _currentIndex = 2;
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();

  BlockchainHelper blockchainHelper = BlockchainHelper();
  List<Transaction> transactions = [];

  Future<void> loadData() async {}

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
          'Blockchain Data',
          style: FontStyles.montserratStyle(18),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Tooltip(
            message: "Search for recent transactions by given address",
            child: IconButton(
              onPressed: () async {
                addNewAlertDialog();
              },
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ) ,
          ),
        ]
      ),
      body: Container(
        color: AppColors.mainBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    Transaction transaction = transactions[index];
                    DateTime formattedDate = DateTime.fromMillisecondsSinceEpoch(transaction.date * 1000,);
                    return ListTile(
                      title: Text('Transaction ID: ${transaction.id}', style: FontStyles.montserratStyle(12, color: AppColors.selectedItemColor),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Block ID: ${transaction.blockId}', style: FontStyles.montserratStyle(12),),
                          Text('Date: ${formattedDate}', style: FontStyles.montserratStyle(12),),
                          Text('Status: ${transaction.status}', style: FontStyles.montserratStyle(12),),
                          Text('Block Number: ${transaction.blockNumber}', style: FontStyles.montserratStyle(12),),
                          Text('Confirmations: ${transaction.confirmations}', style: FontStyles.montserratStyle(12),),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNavigationBar(
        currentIndex: _currentIndex,
      ),
    );
  }

  void addNewAlertDialog() {
    controller1.text = "0x71C7656EC7ab88b098defB751B7401B5f6d8976F";
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
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Transactions by address',
                    style: FontStyles.montserratStyle(18, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                TextField(
                  controller: controller1,
                  style: FontStyles.montserratStyle(15, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: FontStyles.montserratStyle(15, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                TextField(
                  controller: controller2,
                  style: FontStyles.montserratStyle(15, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Protocol',
                    labelStyle: FontStyles.montserratStyle(15, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03125),
                TextField(
                  controller: controller3,
                  style: FontStyles.montserratStyle(15, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Network',
                    labelStyle: FontStyles.montserratStyle(15, color: Colors.white),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                ElevatedButton(
                    child: Text(
                      "Search",
                      style: FontStyles.montserratStyle(14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBackgroundColor,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.75, MediaQuery.of(context).size.height * 0.05),
                    ),
                    onPressed: () async {
                      List<Transaction> auxTransactionsList = await blockchainHelper.fetchTransactionsForAddress(controller1.text.toString());
                      setState(() {
                        transactions = auxTransactionsList;
                      });
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          ),
        );
      },
    );
  }
}
