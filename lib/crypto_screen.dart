import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'api_manager.dart';

class AdBannerWithCloseButton extends StatefulWidget {
  final String adUnitId;
  final AdmobBannerSize adSize;

  AdBannerWithCloseButton({
    required this.adUnitId,
    required this.adSize,
  });

  @override
  _AdBannerWithCloseButtonState createState() =>
      _AdBannerWithCloseButtonState();
}

class _AdBannerWithCloseButtonState extends State<AdBannerWithCloseButton> {
  bool isAdVisible = true;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isAdVisible,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.0),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            AdmobBanner(
              adUnitId: widget.adUnitId,
              adSize: widget.adSize,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isAdVisible = false;
                  });
                },
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CryptoScreen extends StatefulWidget {
  @override
  _CryptoScreenState createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  List<dynamic> newsList = [];
  bool isRefreshing = false;

  @override
  void initState() {
    Admob.requestTrackingAuthorization();
    super.initState();
    fetchCryptoNews();
  }

  Future<void> fetchCryptoNews() async {
    try {
      List<dynamic> cryptoNews = await ApiManager.fetchNews('crypto');
      setState(() {
        newsList = cryptoNews;
      });
    } catch (e) {
      print('Error fetching crypto news: $e');
      // Handle error
    }
  }

  Future<void> _refreshNews() async {
    setState(() {
      isRefreshing = true;
    });

    await fetchCryptoNews();

    // Shuffle the news list after refreshing
    setState(() {
      newsList.shuffle();
      isRefreshing = false;
    });
  }

  void _openNewsDetailPage(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // AdMob Banner with Close Button
            AdBannerWithCloseButton(
              adUnitId: getBannerAdUnitId()!,
              adSize: AdmobBannerSize.BANNER,
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: isRefreshing
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : ListView.builder(
                itemCount: newsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 2.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(newsList[index]['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(newsList[index]['description']),
                          SizedBox(height: 8.0),
                          Image.network(
                            newsList[index]['urlToImage'] ?? '',
                            height: 100.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      onTap: () {
                        _openNewsDetailPage(newsList[index]['url']);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return null;
  }
}
