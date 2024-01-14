// main_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trading_app/quiz_screen.dart';
import 'crypto_list_screen.dart';
import 'crypto_screen.dart';
import 'stocks_screen.dart';
import 'charts_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    ChartsScreen(),
    CryptoScreen(),
    StocksScreen(),
    CryptoListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    bottomNavigationBar: BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
    icon: Icon(Icons.bar_chart),
    label: 'Charts',
      backgroundColor: Colors.yellow,
    ),
    BottomNavigationBarItem(
    icon: Icon(CupertinoIcons.bitcoin_circle_fill),
    label: 'Crypto',
      backgroundColor: Colors.yellow,
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.trending_up),
    label: 'Stocks',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.question_answer),
    label: 'Quiz',
    ),
    ],
      backgroundColor: Colors.greenAccent,
    currentIndex: _selectedIndex,
    selectedItemColor: Colors.black,
    onTap: _onItemTapped,
    // Set the background color here


    ),
    );}}