import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admob_flutter/admob_flutter.dart'; // Import the AdMob package
import 'dart:async';
import 'api_manager.dart';

class StocksScreen extends StatefulWidget {
  @override
  _StocksScreenState createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  List<dynamic> newsList = [];
  String? errorMessage;
  bool isRefreshing = false;

  // AdMob Interstitial Ad
  AdmobInterstitial? interstitialAd;
  int adCounter = 0;

  @override
  void initState() {
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

    // Load the interstitial ad
    interstitialAd?.load();

    // Start a timer to show interstitial ads every 5 seconds
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      // Show an interstitial ad every 5 seconds
      if (adCounter >= 5) {
        showInterstitialAd();
        adCounter = 0; // Reset the counter
      } else {
        adCounter++;
      }
    });

    fetchStocksNews();
  }

  // Function to show the interstitial ad
  void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
    }
  }

  Future<void> fetchStocksNews() async {
    try {
      List<dynamic> stocksNews = await ApiManager.fetchNews('stocks');
      setState(() {
        newsList = stocksNews;
      });
    } catch (e) {
      errorMessage = 'Failed to load stocks news';
      // Handle error
    }
  }

  Future<void> _refreshNews() async {
    setState(() {
      isRefreshing = true;
    });

    await fetchStocksNews();

    // Shuffle the news list after refreshing
    setState(() {
      newsList.shuffle();
      isRefreshing = false;
    });
  }

  void _openNewsDetailPage(String? url) async {
    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    // Dispose of the interstitial ad when the screen is disposed
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: errorMessage != null
          ? Center(
        child: Text(errorMessage!),
      )
          : Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: isRefreshing
            ? Center(
          child: CircularProgressIndicator(),
        )
            : newsList == null
            ? Center(
          child: Text('No stocks news available'),
        )
            : ListView.builder(
          itemCount: newsList!.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 2.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(newsList![index]['title'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(newsList![index]['description'] ?? ''),
                    SizedBox(height: 8.0),
                    Image.network(
                      newsList![index]['urlToImage'] ?? '',
                      height: 100.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                onTap: () {
                  _openNewsDetailPage(newsList![index]['url']);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
