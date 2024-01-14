// Import necessary packages and files
import 'package:flutter/material.dart';

class SrBot {
  // Function to calculate support and resistance levels
  List<Map<String, double>> calculateSupportResistance(List<double> prices, int sensitivity) {
    List<Map<String, double>> levels = [];

    // Logic to calculate support and resistance levels based on sensitivity
    for (int i = 1; i <= sensitivity; i++) {
      double resistance = prices.reduce((a, b) => a > b ? a : b);
      double support = prices.reduce((a, b) => a < b ? a : b);

      levels.add({'Resistance': resistance, 'Support': support});

      prices.remove(resistance);
      prices.remove(support);
    }

    return levels;
  }
}
