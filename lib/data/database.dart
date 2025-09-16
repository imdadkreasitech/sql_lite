import 'dart:io';

import 'package:drift/drift.dart';
// These imports are only needed to open the database
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sql_lite/data/category.dart';
import 'package:sql_lite/data/transaction.dart';
import 'package:sql_lite/data/transaction_w_category.dart';

part 'database.g.dart';

@DriftDatabase(
  // relative import for the drift file. Drift also supports `package:`
  // imports
  tables: [Categories, Transactions],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Category>> getAllCategoryRepo(int type) =>
      (select(categories)..where((tbl) => tbl.type.equals(type))
      // ..orderBy([(t) => OrderingTerm(expression: t.name)])
      ).get();

  Future updateCategoryRepo(int id, String name) => (update(categories)
    ..where((tbl) => tbl.id.equals(id))).write(
    CategoriesCompanion(name: Value(name), updateAt: Value(DateTime.now())),
  );

  Future deleteCategoryRepo(int id) =>
      (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  // (update(categories)
  //   ..where((tbl) => tbl.id.equals(id))).write(
  //   CategoriesCompanion(deleteAt: Value(DateTime.now())),
  // );

  Stream<List<TransactionWCategory>> getAllTransactionByDateRepo(
    DateTime date,
  ) {
    final query = select(transactions).join([
      leftOuterJoin(
        categories,
        categories.id.equalsExp(transactions.categoryI),
      ),
    ])
      ..where(transactions.transactionDate.year.equals(date.year) &
          transactions.transactionDate.month.equals(date.month) &
          transactions.transactionDate.day.equals(date.day));
    // ..orderBy([
    //   OrderingTerm(
    //     expression: transactions.transactionDate,
    //     mode: OrderingMode.desc,
    //   ),
    // ]);
    print(" query: $query");

    return query.watch().map(
      (rows) =>
          rows.map((row) {
            return TransactionWCategory(
              transaction: row.readTable(transactions),
              category: row.readTable(categories),
            );
          }).toList(),
    );
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
