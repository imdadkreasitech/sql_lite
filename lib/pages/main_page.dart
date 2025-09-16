import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sql_lite/pages/category_page.dart';
import 'package:sql_lite/pages/home_page.dart';
import 'package:sql_lite/pages/transactions_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _page;

  late int _selectedIndex;

  void onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateview(int idx, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }

      _selectedIndex = idx;
      _page = [HomePage(selectedDate: selectedDate), CategoryPage()];
    });
  }

  @override
  void initState() {
    super.initState();
    updateview(0, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          (_selectedIndex == 0)
              ? CalendarAppBar(
                backButton: false,
                accent: Colors.deepPurpleAccent,
                onDateChanged:
                    (value) => {
                      print("value: $value"),
                      setState(() {
                        updateview(0, value);
                      }),
                    },
                firstDate: DateTime.now().subtract(Duration(days: 140)),
                lastDate: DateTime.now(),
              )
              : AppBar(title: Text("Category"), centerTitle: true),
      floatingActionButton: Visibility(
        visible: _selectedIndex == 0,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionsPage(transaction: null),
              ),
            ).then((value) => setState(() {}));
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                updateview(0, DateTime.now());
              },
              icon: const Icon(Icons.home),
            ),
            SizedBox(width: 20),
            IconButton(
              onPressed: () {
                updateview(1, null);
              },
              icon: const Icon(Icons.list),
            ),
          ],
        ),
      ),
      body: _page[_selectedIndex],
    );
  }
}
