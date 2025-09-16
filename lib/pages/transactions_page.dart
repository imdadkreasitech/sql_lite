import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:sql_lite/data/database.dart';
import 'package:sql_lite/data/transaction_w_category.dart';

class TransactionsPage extends StatefulWidget {
  final TransactionWCategory? transaction;
  const TransactionsPage({super.key, required this.transaction});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final AppDb database = AppDb();
  bool isExpense = true;
  Category? selectedCategory;
  final TextEditingController dateC = TextEditingController();
  final TextEditingController amountC = TextEditingController();
  final TextEditingController detailC = TextEditingController();
  Future<List<Category>>? _categoryFuture;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      updateTransactionView(widget.transaction!);
    } else {
      // _categoryFuture = getAllCategory(0);
      _categoryFuture = getAllCategory(isExpense ? 0 : 1);
    }
  }

  void updateTransactionView(TransactionWCategory transaction) {
    setState(() {
      isExpense = transaction.category.type == 0;
      selectedCategory = transaction.category;
      amountC.text = transaction.transaction.amount.toString();
      detailC.text = transaction.transaction.name;
      dateC.text =
          "${transaction.transaction.transactionDate.day}-${transaction.transaction.transactionDate.month}-${transaction.transaction.transactionDate.year}";
      _categoryFuture = getAllCategory(isExpense ? 0 : 1);
    });
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future insertTransaction(
    String name,
    int categoryId,
    int amount,
    DateTime transactionDate,
  ) async {
    final row = await database
        .into(database.transactions)
        .insertReturning(
          TransactionsCompanion(
            name: Value(name),
            categoryI: Value(categoryId),
            amount: Value(amount),
            transactionDate: Value(transactionDate),
            createdAt: Value(DateTime.now()),
            updateAt: Value(DateTime.now()),
          ),
        );

    print("Hasil: $row");
  }

  Future updateTransaction(
    int id,
    String name,
    int categoryId,
    int amount,
    DateTime transactionDate,
  ) async {
    await database.updateTransactionRepo(
      id,
      name,
      categoryId,
      amount,
      transactionDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transactions")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Switch(
                      value: isExpense,
                      onChanged: (bool value) {
                        setState(() {
                          isExpense = value;
                          selectedCategory = null;
                          _categoryFuture = getAllCategory(isExpense ? 0 : 1);
                        });
                      },
                      inactiveTrackColor: Colors.green[200],
                      inactiveThumbColor: Colors.green,
                      activeColor: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text(isExpense ? "Expense" : "Income"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: amountC,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Amount",
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Categrory"),
              ),
              FutureBuilder<List<Category>>(
                future: _categoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No categories found'));
                  } else {
                    final categoryList = snapshot.data!;
                    selectedCategory ??= categoryList.first;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<Category>(
                        isExpanded: true,
                        value: selectedCategory,
                        items:
                            categoryList
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16),
              //   child: DropdownButton(
              //     isExpanded: true,
              //     value: selectedCategory,
              //     items:
              //         categories
              //             .map(
              //               (e) => DropdownMenuItem(value: e, child: Text(e)),
              //             )
              //             .toList(),
              //     onChanged: (value) {
              //       setState(() {
              //         selectedCategory = value!;
              //       });
              //     },
              //   ),
              // ),
              // SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  readOnly: true,
                  controller: dateC,
                  decoration: InputDecoration(labelText: "Enter Date"),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                      setState(() {
                        dateC.text = formattedDate;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: detailC,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Detail",
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedCategory == null ||
                        amountC.text.isEmpty ||
                        detailC.text.isEmpty ||
                        dateC.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }
                    if (widget.transaction != null) {
                      updateTransaction(
                        widget.transaction!.transaction.id,
                        detailC.text,
                        selectedCategory!.id,
                        int.parse(amountC.text),
                        DateTime.now(),
                      );
                      Navigator.pop(context);
                      return;
                    }
                    insertTransaction(
                      detailC.text,
                      selectedCategory!.id,
                      int.parse(amountC.text),
                      DateTime.now(),
                    );
                    amountC.clear();
                    detailC.clear();
                    dateC.clear();
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Text("Add Transaction"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
