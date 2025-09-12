import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:sql_lite/pages/category_page.dart';
import 'package:sql_lite/pages/home_page.dart';
import 'package:sql_lite/pages/transactions_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Widget> _page = [HomePage(), CategoryPage()];

  int _selectedIndex = 0;

  void onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          (_selectedIndex == 0)
              ? CalendarAppBar(
                backButton: false,
                accent: Colors.deepPurpleAccent,
                onDateChanged: (value) => print(value),
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
              MaterialPageRoute(builder: (context) => TransactionsPage()),
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
                onTap(0);
              },
              icon: const Icon(Icons.home),
            ),
            SizedBox(width: 20),
            IconButton(
              onPressed: () {
                onTap(1);
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
