import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quiz_screen.dart';


class CryptoListScreen extends StatefulWidget {
  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  List<CryptoData> cryptoDataList = [];
  DateTime bitcoinHalvingDate = DateTime(2024, 4, 17);
  late Timer timer;
  Duration timeLeft = Duration();
  bool isDateVisible = true;

  void calculateTimeLeft() {
    DateTime now = DateTime.now();
    Duration difference = bitcoinHalvingDate.difference(now);
    setState(() {
      timeLeft = difference.isNegative ? Duration() : difference;
      isDateVisible = !isDateVisible;
    });
  }
  String formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    return '$days:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }



  void showQuizDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuizDialog();
      },
    );
  }

  void compareGainer() {
    // Sort the cryptoDataList based on 1-hour price change in descending order
    cryptoDataList.sort((a, b) => b.priceChange1h.compareTo(a.priceChange1h));

    // Take the top 5 cryptocurrencies based on 1-hour price change
    final top5GainerCryptoList = cryptoDataList.take(5).toList();

    // Show a dialog box with a table displaying the top 5 gained cryptocurrencies
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Top 5 Gained Cryptos in 1 Hour',
            style: TextStyle(
              color: Colors.black, // Set text color to black
              fontWeight: FontWeight.bold, // Set text to bold
            ),
          ),
          backgroundColor: Colors.yellow, // Set the background color to fawn
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Text('Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Current Price', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Volume', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Change (1h)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
              rows: top5GainerCryptoList.map(
                    (crypto) {
                  return DataRow(
                    cells: [
                      DataCell(Text(crypto.name, style: TextStyle(color: Colors.black))),
                      DataCell(Text('\$${crypto.currentPrice.toStringAsFixed(6)}', style: TextStyle(color: Colors.black))),
                      DataCell(Text('${crypto.volume.toStringAsFixed(6)}', style: TextStyle(color: Colors.black))),
                      DataCell(Text('${crypto.priceChange1h.toStringAsFixed(6)}%', style: TextStyle(color: Colors.green))),
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }


  // Change the alertbox color to fawn(#C8A951)
  // and make text color black and bold
  void compareLoser() {
    // Sort the cryptoDataList based on 1-hour price change in ascending order
    cryptoDataList.sort((a, b) => a.priceChange1h.compareTo(b.priceChange1h));

    // Take the top 5 cryptocurrencies based on 1-hour price change (losers)
    final top5LoserCryptoList = cryptoDataList.take(5).toList();

    // Show a dialog box with a table displaying the top 5 lost cryptocurrencies
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Top 5 Lost Cryptos in 1 Hour',
            style: TextStyle(
              color: Colors.black, // Set text color to black
              fontWeight: FontWeight.bold, // Set text to bold
            ),
          ),
          backgroundColor: Colors.yellow, // Set the background color to fawn
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Text('Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                DataColumn(
                  label: Text('Current Price', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                DataColumn(
                  label: Text('Volume', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                DataColumn(
                  label: Text('Change (1h)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),

              ],
              rows: top5LoserCryptoList.map(
                    (crypto) {
                  return DataRow(
                    cells: [
                      DataCell(Text(crypto.name, style: TextStyle(color: Colors.black))),
                      DataCell(Text('\$${crypto.currentPrice.toStringAsFixed(6)}', style: TextStyle(color: Colors.black))),
                      DataCell(Text('${crypto.volume.toStringAsFixed(6)}', style: TextStyle(color: Colors.black))),
                      DataCell(Text('${crypto.priceChange1h.toStringAsFixed(6)}%', style: TextStyle(color: Colors.red))), // Use the dark green color
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    calculateTimeLeft();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => calculateTimeLeft());
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('https://api.coingecko.com/api/v3/coins/markets').replace(queryParameters: {
        'vs_currency': 'usd',
        'order': 'market_cap_desc',
        'per_page': '100',
        'page': '1',
        'sparkline': 'false',
        'price_change_percentage': '1h,24h,7d',
      }),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        cryptoDataList = responseData.map((data) => CryptoData.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void compareVolume() {
    // Sort the cryptoDataList based on volume in descending order
    cryptoDataList.sort((a, b) => b.volume.compareTo(a.volume));

    // Take the top 5 cryptocurrencies based on volume
    final top5VolumeCryptoList = cryptoDataList.take(5).toList();

    // Show a dialog box with a table displaying the top 5 cryptocurrencies by volume
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Top 5 Cryptos by Volume'),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Current Price')),
                DataColumn(label: Text('Volume')),
                DataColumn(label: Text('Change (1h)')),
              ],
              rows: top5VolumeCryptoList.map(
                    (crypto) {
                  return DataRow(
                    cells: [
                      DataCell(Text(crypto.name)),
                      DataCell(Text('\$${crypto.currentPrice.toStringAsFixed(2)}')),
                      DataCell(Text('${crypto.volume.toString()}')),
                      DataCell(Text('${crypto.priceChange1h.toString()}%')),
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Prices'),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: Icon(Icons.compare),
            onPressed: compareVolume,
          ),
          IconButton(
            icon: Icon(Icons.trending_up),
            onPressed: () {
              compareGainer();
              // Add code to handle Gainer button click
            },
          ),
          IconButton(
            icon: Icon(Icons.trending_down),
            onPressed: () {
              compareLoser();
              // Add code to handle Loser button click
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: showQuizDialog,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('docs/assets/images/binage.jpg'),  // Replace with your image asset path
            fit: BoxFit.fill,
          ),
        ),
        child: cryptoDataList.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'The time until the next Bitcoin Halving in:',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              AnimatedOpacity(
                opacity: isDateVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500), // Adjust the duration as needed
                child: Text(
                  ' ${formatDuration(timeLeft)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: cryptoDataList.length,
          itemBuilder: (context, index) {
            final crypto = cryptoDataList[index];
            return ListTile(
              title: Text(crypto.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${crypto.currentPrice.toStringAsFixed(8)}'),
                  Text('Volume: ${crypto.volume.toStringAsFixed(8)}'),
                  Text('Change (1h): ${crypto.priceChange1h.toString()}%'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TopVolumeCryptoScreen extends StatelessWidget {
  final List<CryptoData> top5VolumeCryptoList;

  TopVolumeCryptoScreen(this.top5VolumeCryptoList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Indicator'),
      ),
      body: DataTable(
        columns: [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Current Price')),
          DataColumn(label: Text('Volume')),
          DataColumn(label: Text('Change (1h)')),
        ],
        rows: top5VolumeCryptoList
            .map(
              (crypto) => DataRow(
            cells: [
              DataCell(Text(crypto.name)),
              DataCell(Text('\$${crypto.currentPrice.toStringAsFixed(2)}')),
              DataCell(Text('${crypto.volume.toString()}')),
              DataCell(Text('${crypto.priceChange1h.toString()}%')),
            ],
          ),
        )
            .toList(),
      ),
    );
  }
}

class CryptoData {
  final String name;
  final double currentPrice;
  final double volume;
  final double priceChange1h;

  CryptoData({
    required this.name,
    required this.currentPrice,
    required this.volume,
    required this.priceChange1h,
  });

  factory CryptoData.fromJson(Map<String, dynamic> json) {
    return CryptoData(
      name: json['name'],
      currentPrice: json['current_price'].toDouble(),
      volume: json['total_volume'].toDouble(),
      priceChange1h: json['price_change_percentage_1h_in_currency'].toDouble(),
    );
  }
}
class TopGainerCryptoScreen extends StatelessWidget {
  final List<CryptoData> top5GainerCryptoList;

  TopGainerCryptoScreen(this.top5GainerCryptoList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top 5 Gained Cryptos in 1 Hour'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Current Price')),
            DataColumn(label: Text('Volume')),
            DataColumn(label: Text('Change (1h)')),
          ],
          rows: top5GainerCryptoList.map(
                (crypto) {
              return DataRow(
                cells: [
                  DataCell(Text(crypto.name)),
                  DataCell(Text('\$${crypto.currentPrice.toStringAsFixed(6)}')),
                  DataCell(Text('${crypto.volume.toStringAsFixed(6)}')),
                  DataCell(Text('${crypto.priceChange1h.toStringAsFixed(6)}%')),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

class TopLoserCryptoScreen extends StatelessWidget {
  final List<CryptoData> top5LoserCryptoList;

  TopLoserCryptoScreen(this.top5LoserCryptoList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top 5 Lost Cryptos in 1 Hour'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Current Price')),
            DataColumn(label: Text('Volume')),
            DataColumn(label: Text('Change (1h)')),
          ],
          rows: top5LoserCryptoList.map(
                (crypto) {
              return DataRow(
                cells: [
                  DataCell(Text(crypto.name)),
                  DataCell(Text('\$${crypto.currentPrice.toStringAsFixed(6)}')),
                  DataCell(Text('${crypto.volume.toStringAsFixed(6)}')),
                  DataCell(Text('${crypto.priceChange1h.toStringAsFixed(6)}%')),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

