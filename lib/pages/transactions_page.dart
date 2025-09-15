import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:sql_lite/data/database.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

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
    _categoryFuture = getAllCategory(isExpense ? 0 : 1);
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
                    database.getAllCategoryRepo(isExpense ? 0 : 1).then((
                      categoryList,
                    ) {
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
                    });
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
