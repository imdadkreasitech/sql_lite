import 'package:flutter/material.dart';
import 'package:sql_lite/data/database.dart';
import 'package:drift/drift.dart' hide Column;

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;

  final AppDb database = AppDb();

  TextEditingController categoryNameC = TextEditingController();

  Future insertCategory(String name, int type) async {
    final row = await database
        .into(database.categories)
        .insertReturning(
          CategoriesCompanion(
            name: Value(name),
            type: Value(type),
            createdAt: Value(DateTime.now()),
            updateAt: Value(DateTime.now()),
          ),
        );

    print("Hasil: $row");
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future updateCategory(int id, String name) async {
    return await database.updateCategoryRepo(id, name);
  }

  void openDialod(Category? category) {
    if (category != null) {
      categoryNameC.text = category.name;
    } else {
      categoryNameC.clear();
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(
                    (isExpense)
                        ? "Add Expense Category"
                        : "Add Income Catagory",
                    style: TextStyle(
                      color: (isExpense) ? Colors.red : Colors.green,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: categoryNameC,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Category Name',
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (category != null) {
                        updateCategory(category.id, categoryNameC.text);
                      } else {
                        insertCategory(categoryNameC.text, (isExpense) ? 0 : 1);
                      }
                      Navigator.of(context).pop();
                      setState(() {});
                      categoryNameC.clear();
                    },
                    child: Text((category != null) ? "Update" : "Add"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch(
                  value: isExpense,
                  onChanged: (bool value) {
                    setState(() {
                      isExpense = value;
                    });
                  },
                  inactiveTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.green,
                  activeColor: Colors.red,
                ),
                IconButton(
                  onPressed: () {
                    openDialod(null);
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),

          FutureBuilder<List<Category>>(
            future: getAllCategory((isExpense) ? 0 : 1),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No categories found.'));
              } else {
                final categories = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ListTile(
                          leading:
                              (isExpense)
                                  ? Icon(Icons.upload, color: Colors.red)
                                  : Icon(Icons.download, color: Colors.green),
                          title: Text(category.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  openDialod(category);
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  database.deleteCategoryRepo(category.id);
                                  setState(() {});
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),

          // Padding(
          //   padding: EdgeInsets.all(16.0),
          //   child: Card(
          //     child: ListTile(
          //       leading:
          //           (isExpense)
          //               ? Icon(Icons.upload, color: Colors.red)
          //               : Icon(Icons.download, color: Colors.green),
          //       title: Text("Oiii"),
          //       trailing: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
          //           IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
