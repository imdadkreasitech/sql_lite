import 'package:flutter/material.dart';
import 'package:sql_lite/data/database.dart';
import 'package:sql_lite/data/transaction_w_category.dart';
import 'package:sql_lite/pages/transactions_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({super.key, required this.selectedDate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  Future<List<TransactionWCategory>> getAllTransactionByDate(
    DateTime date,
  ) async {
    return await database.getAllTransactionByDateRepo(date).first;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(Icons.download, color: Colors.green),
                        ),
                        SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Income",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Rp.10.000.000",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(Icons.upload, color: Colors.redAccent),
                        ),
                        SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expense",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Rp.1.000.000",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Transaction History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            StreamBuilder(
              stream: database.getAllTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print(
                    "data: ${snapshot.hasData} length: ${snapshot.data?.length}",
                  );
                  return Center(child: Text("No transactions found."));
                } else {
                  final transactions = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          child: ListTile(
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => TransactionsPage(
                                              transaction: transaction,
                                              // transaction: transaction.transaction,
                                              // category: transaction.category,
                                            ),
                                      ),
                                    ).then((value) => setState(() {}));
                                  },
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                ),
                                SizedBox(width: 16),

                                IconButton(
                                  onPressed: () {
                                    database.deleteTransactionRepo(
                                      transaction.transaction.id,
                                    );
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                            title: Text(transaction.transaction.name),
                            subtitle: Text(
                              "${transaction.category.name} - Rp.${transaction.transaction.amount}",
                            ),
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                transaction.category.type == 0
                                    ? Icons.upload
                                    : Icons.download,
                                color:
                                    transaction.category.type == 0
                                        ? Colors.red
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),

            // StreamBuilder(
            //   // stream: getAllTransactionByDate(widget.selectedDate),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Center(child: CircularProgressIndicator());
            //     } else if (snapshot.hasError) {
            //       return Center(child: Text("Error: ${snapshot.error}"));
            //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return Center(child: Text("No transactions found."));
            //     } else {
            //       final transactions = snapshot.data!;
            //       return ListView.builder(
            //         shrinkWrap: true,
            //         physics: NeverScrollableScrollPhysics(),
            //         itemCount: transactions.length,
            //         itemBuilder: (context, index) {
            //           final transaction = transactions[index];
            //           return Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 16),
            //             child: Card(
            //               child: ListTile(
            //                 trailing: Row(
            //                   mainAxisSize: MainAxisSize.min,
            //                   children: [
            //                     Icon(Icons.edit, color: Colors.blue),
            //                     SizedBox(width: 16),
            //                     Icon(Icons.delete, color: Colors.red),
            //                   ],
            //                 ),
            //                 title: Text("Rp.${transaction.transaction.amount}"),
            //                 subtitle: Text(transaction.category.name),
            //                 leading: Container(
            //                   decoration: BoxDecoration(
            //                     color: Colors.white,
            //                     borderRadius: BorderRadius.circular(8.0),
            //                   ),
            //                   child: Icon(
            //                     transaction.transaction.type == 0
            //                         ? Icons.upload
            //                         : Icons.download,
            //                     color: transaction.transaction.type == 0
            //                         ? Colors.red
            //                         : Colors.green,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     }
            //   },
            // )
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Card(
            //     child: ListTile(
            //       trailing: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Icon(Icons.edit, color: Colors.blue),
            //           SizedBox(width: 16),
            //           Icon(Icons.delete, color: Colors.red),
            //         ],
            //       ),
            //       title: Text("Rp.200.000"),
            //       subtitle: Text("Shopping"),
            //       leading: Container(
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(8.0),
            //         ),
            //         child: Icon(Icons.download, color: Colors.green),
            //       ),
            //     ),
            //   ),
            // ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Card(
            //     child: ListTile(
            //       trailing: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Icon(Icons.edit, color: Colors.blue),
            //           SizedBox(width: 16),
            //           Icon(Icons.delete, color: Colors.red),
            //         ],
            //       ),
            //       title: Text("Rp.10.000.000"),
            //       subtitle: Text("Gaji Bulanan"),
            //       leading: Container(
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(8.0),
            //         ),
            //         child: Icon(Icons.download, color: Colors.green),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
