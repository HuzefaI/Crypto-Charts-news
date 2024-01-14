import 'dart:async';
import 'dart:convert';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trading_app/candlestick/models/indicator.dart';
import 'package:flutter_trading_app/candlestick/widgets/toolbar_action.dart';
import 'package:flutter_trading_app/srbot.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'candle_ticker_model.dart';
import 'candlestick/models/candle.dart';
import 'indicators/bollinger_bands_indicator.dart';
import 'indicators/weighted_moving_average.dart';
import 'repository.dart';
import 'candlestick/candlesticks.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  // Add AdMob interstitial ad
  AdmobInterstitial? interstitialAd;
  int adCounter = 0;
  SrBot srBot = SrBot();
  BinanceRepository repository = BinanceRepository();

  List<Candle> candles = [];
  WebSocketChannel? _channel;
  bool themeIsDark = true;
  String currentInterval = "1m";
  final intervals = [
    '1m',
    '3m',
    '5m',
    '15m',
    '30m',
    '1h',
    '2h',
    '4h',
    '6h',
    '8h',
    '12h',
    '1d',
    '3d',
    '1w',
    '1M',
  ];
  List<String> symbols = [];
  String currentSymbol = "";
  List<Indicator> indicators = [
    BollingerBandsIndicator(
      length: 20,
      stdDev: 2,
      upperColor: const Color(0xFF2962FF),
      basisColor: const Color(0xFFFF6D00),
      lowerColor: const Color(0xFF2962FF),
    ),
    WeightedMovingAverageIndicator(
      length: 100,
      color: Colors.green.shade600,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto App',
      theme: themeIsDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: themeIsDark ? Colors.blueGrey[900] : Colors.amber,
          title: Text(
            "Crypto App",
            style: TextStyle(
              color: themeIsDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  themeIsDark = !themeIsDark;
                });
              },
              icon: Icon(
                themeIsDark
                    ? Icons.wb_sunny_sharp
                    : Icons.nightlight_round_outlined,
              ),
            )
          ],
        ),
        body: Center(
          child: StreamBuilder(
            stream: _channel == null ? null : _channel!.stream,
            builder: (context, snapshot) {
              updateCandlesFromSnapshot(snapshot);
              return Column(
                children: [
                  Container(
                    color: themeIsDark ? const Color(0xFF191B20) : Colors.white,
                    height: 80,
                    width: double.maxFinite,
                    child: Padding(
                      padding: const  EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!snapshot.hasData)
                            const Text(
                              'Loading... ',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          if (snapshot.hasData)
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return SymbolsSearchModal(
                                      onSelect: (symbol) {
                                        setState(() {
                                          currentSymbol = symbol;
                                          fetchCandles(symbol, currentInterval);
                                        });
                                      },
                                      symbols: symbols,
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child:Text(
                                      currentSymbol,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  // Add an IconButton next to the Text widget
                                  IconButton(
                                    icon: Icon(Icons.search, color:Colors.white),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) {
                                          return SymbolsSearchModal(
                                            onSelect: (symbol) {
                                              setState(() {
                                                currentSymbol = symbol;
                                                fetchCandles(symbol, currentInterval);
                                              });
                                            },
                                            symbols: symbols,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),


                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _showSupportResistanceDialog(),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.yellow,
                            ),
                            child: Icon(
                              CupertinoIcons.graph_square,
                              size: 32, // Adjust the size as needed
                            ),
                          ),


                          const SizedBox(width: 10),

                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Close',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                FittedBox(
                                  child: Text(
                                    candles.isNotEmpty
                                        ? candles.last.close.toStringAsFixed(2)
                                        : "0.00",
                                    style: TextStyle(
                                      fontSize: 12,
                                      // Add other styling properties as needed
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'High',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                FittedBox(
                                  child: Text(
                                    candles.isNotEmpty
                                        ? candles.last.high.toStringAsFixed(2)
                                        : "0.00",
                                    style: TextStyle(
                                      fontSize: 12,
                                      // Add other styling properties as needed
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Low',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                FittedBox(
                                  child: Text(
                                    candles.isNotEmpty
                                        ? candles.last.low.toStringAsFixed(2)
                                        : "0.00",
                                    style: TextStyle(
                                      fontSize: 12,
                                      // Add other styling properties as needed
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Open',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                FittedBox(
                                  child: Text(
                                    candles.isNotEmpty
                                        ? candles.last.open.toStringAsFixed(2)
                                        : "0.00",
                                    style: TextStyle(
                                      fontSize: 12,
                                      // Add other styling properties as needed
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Show Streaming data in json form
                  // Text(snapshot.hasData ? '${snapshot.data}' : ''),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Candlesticks(
                      key: Key(currentSymbol + currentInterval),
                      indicators: indicators,
                      candles: candles,
                      onLoadMoreCandles: loadMoreCandles,
                      onRemoveIndicator: (String indicator) {
                        setState(() {
                          indicators = [...indicators];
                          indicators.removeWhere(
                                  (element) => element.name == indicator);
                        });

                      },
                      actions: [


                        ToolBarAction(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Center(
                                  child: Container(
                                    width: 200,
                                    color: Theme.of(context).backgroundColor,
                                    child: Wrap(
                                      children: intervals
                                          .map((e) => Padding(
                                        padding:
                                        const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 50,
                                          height: 30,
                                          child: RawMaterialButton(
                                            elevation: 0,
                                            fillColor:
                                            const Color(0xFF494537),
                                            onPressed: () {
                                              fetchCandles(
                                                  currentSymbol, e);
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                color:
                                                Color(0xFFF0B90A),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            currentInterval,
                          ),
                        ),

                        ToolBarAction(
                          width: 100,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SymbolsSearchModal(
                                  symbols: symbols,
                                  onSelect: (value) {
                                    fetchCandles(value, currentInterval);
                                  },
                                );
                              },
                            );
                          },

                          child: Text(
                            currentSymbol,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  Future<void> _showSupportResistanceDialog() async {
    // Ensure you have actual candle prices here
    List<double> candlePrices = candles.map((candle) => candle.close).toList();

    int sensitivity = 10; // You can adjust the sensitivity here

    // Call the calculateSupportResistance method from SrBot
    List<Map<String, double>> levels = srBot.calculateSupportResistance(candlePrices, sensitivity);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Support and Resistance Levels',
            style: TextStyle(color: Colors.white),
          ),


          backgroundColor: Colors.black, // Set the dialog box background color to black
          content: SingleChildScrollView(
            child: Table(
              defaultColumnWidth: IntrinsicColumnWidth(),
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Support',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green), // Set support text color to dark green
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Resistance',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red), // Set resistance text color to red
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            ' ${levels[0]['Support'] ?? '-'}',
                            style: TextStyle(fontSize: 16, color: Colors.green), // Set support value text color to dark green
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            ' ${levels[0]['Resistance'] ?? '-'}',
                            style: TextStyle(fontSize: 16, color: Colors.red), // Set resistance value text color to red
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            ' ${levels[1]['Support'] ?? '-'}',
                            style: TextStyle(fontSize: 16, color: Colors.green), // Set support value text color to dark green
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            ' ${levels[1]['Resistance'] ?? '-'}',
                            style: TextStyle(fontSize: 16, color: Colors.red), // Set resistance value text color to red
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            ' ${levels[2]['Support'] ?? '-'}',
                            style: TextStyle(fontSize: 16, color: Colors.green), // Set support value text color to dark green
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            ' ${levels[2]['Resistance'] ?? '-'}',
                            style: TextStyle(fontSize: 16, color: Colors.red), // Set resistance value text color to red
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Add more TableRows if you have more levels
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    if (_channel != null) _channel!.sink.close();
    super.dispose();
  }

  Future<void> fetchCandles(String symbol, String interval) async {
    // close current channel if exists
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    // clear last candle list
    setState(() {
      candles = [];
      currentInterval = interval;
    });

    try {
      // load candles info
      final data =
      await repository.fetchCandles(symbol: symbol, interval: interval);
      // connect to binance stream
      _channel =
          repository.establishConnection(symbol.toLowerCase(), currentInterval);
      // update candles
      setState(() {
        candles = data;
        currentInterval = interval;
        currentSymbol = symbol;
      });
    } catch (e) {
      // handle error
      return;
    }
  }

  Future<List<String>> fetchSymbols() async {
    try {
      // load candles info
      final data = await repository.fetchSymbols();
      return data;
    } catch (e) {
      // handle error
      return [];
    }
  }

  @override
  void initState() {
    fetchSymbols().then((value) {
      symbols = value;
      if (symbols.isNotEmpty) fetchCandles(symbols[0], currentInterval);
    });
    super.initState();
    // Initialize the interstitial ad
    interstitialAd = AdmobInterstitial(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.closed) {
          // Load a new interstitial ad after it's closed
          interstitialAd?.load();
        }
      },
    );
    //change1

    // Load the interstitial ad
    interstitialAd?.load();

    // Start a timer to show interstitial ads every 5 seconds
    Timer.periodic(Duration(seconds: 100), (Timer timer) {
      // Show an interstitial ad every 5 seconds
      if (adCounter >= 100) {
        showInterstitialAd();
        adCounter = 0; // Reset the counter
      } else {
        adCounter++;
      }
    });

  }

  Future<void> loadMoreCandles() async {
    try {
      // load candles info
      final data = await repository.fetchCandles(
          symbol: currentSymbol,
          interval: currentInterval,
          endTime: candles.last.date.millisecondsSinceEpoch);
      candles.removeLast();
      setState(() {
        candles.addAll(data);
      });
    } catch (e) {
      // handle error
      return;
    }
  }

  void updateCandlesFromSnapshot(AsyncSnapshot<Object?> snapshot) {
    if (candles.isEmpty) return;
    if (snapshot.data != null) {
      final map = jsonDecode(snapshot.data as String) as Map<String, dynamic>;
      if (map.containsKey("k") == true) {
        final candleTicker = CandleTickerModel.fromJson(map);

        // cehck if incoming candle is an update on current last candle, or a new one
        if (candles[0].date == candleTicker.candle.date &&
            candles[0].open == candleTicker.candle.open) {
          // update last candle
          candles[0] = candleTicker.candle;
        }
        // check if incoming new candle is next candle so the difrence
        // between times must be the same as last existing 2 candles
        else if (candleTicker.candle.date.difference(candles[0].date) ==
            candles[0].date.difference(candles[1].date)) {
          // add new candle to list
          candles.insert(0, candleTicker.candle);
        }
      }
    }
  }
  void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
    }
  }
}
class CustomTextField extends StatelessWidget {
  // ... your existing code ...
  final void Function(String) onChanged;
  const CustomTextField({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material( // This is the added wrapper
      child: TextField(
        // ... your existing TextField properties ...
        decoration: InputDecoration(
          labelText: 'Search Symbol',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.search),
        ),
        onChanged: onChanged,
      ),
    );
  }
}




class SymbolsSearchModal extends StatefulWidget {
  final Function(String symbol) onSelect;
  final List<String> symbols;

  const SymbolsSearchModal({Key? key, required this.onSelect, required this.symbols}) : super(key: key);

  @override
  _SymbolSearchModalState createState() => _SymbolSearchModalState();
}

class _SymbolSearchModalState extends State<SymbolsSearchModal> {
  String symbolSearch = "";

  @override
  Widget build(BuildContext context) {
    // Wrap the Container in a Material widget to ensure that ListTile finds Material ancestor
    return Material(
      child: Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            CustomTextField(
              onChanged: (value) {
                setState(() {
                  symbolSearch = value;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.symbols.length,
                itemBuilder: (context, index) {
                  String symbol = widget.symbols[index];
                  if (symbolSearch.isEmpty || symbol.toLowerCase().contains(symbolSearch.toLowerCase())) {
                    return ListTile(
                      title: Text(symbol),
                      onTap: () {
                        widget.onSelect(symbol);
                        Navigator.of(context).pop();
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}