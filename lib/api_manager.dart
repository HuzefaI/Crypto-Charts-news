
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiManager {
  // static String interstitialAdUnitId = '';
  static Future<List<dynamic>> fetchNews(String keyword) async {
    final String apiKey = '790f5c3c2c5f4c79bf4fd56f3d636508';
    final Uri uri = Uri.parse('https://newsapi.org/v2/everything?q=$keyword&apiKey=$apiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body)['articles'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}