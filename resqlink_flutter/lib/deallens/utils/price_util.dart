import 'package:intl/intl.dart';

class PriceUtil {
  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Per-category USD -> INR multipliers reflecting Indian market purchasing power
  static const Map<String, double> categoryMultipliers = {
    'smartphones': 83.0,
    'laptops': 83.0,
    'headphones': 83.0,
    'mobiles': 83.0,
    'electronics': 83.0,
    'fashion': 35.0,
    'shoes': 40.0,
    'sneakers': 40.0,
    'watches': 50.0,
    'home decor': 30.0,
    'home': 30.0,
    'beauty': 25.0,
    'bags': 35.0,
  };

  static const double defaultMultiplier = 50.0;

  /// Convert to realistic INR price with NO decimals.
  /// If isLive == true, price is already in INR (from SerpApi), so skip multiplier!
  static double convertToInr({
    required double rawPrice,
    required String category,
    bool isLive = false,
  }) {
    if (rawPrice <= 0) return 0.0;

    if (isLive) {
      return rawPrice.roundToDouble();
    }

    final key = category.trim().toLowerCase();
    final multiplier = categoryMultipliers[key] ?? defaultMultiplier;
    final inr = rawPrice * multiplier;

    return inr.roundToDouble();
  }

  /// Backward-compatibility helper for CurrencyFormatter
  static double convertUsdToInr(double usd, [String category = 'default']) =>
      convertToInr(rawPrice: usd, category: category);

  /// Round to nearest whole rupee with zero decimals
  static double roundToNearestRupee(double amount) {
    return amount.roundToDouble();
  }

  /// Round to realistic Indian retail price with no decimals
  static double roundToRetailPrice(double amount) {
    return amount.roundToDouble();
  }

  /// Format an INR price with Indian number grouping and NO decimals (e.g. ₹12,499)
  static String format(double price) {
    return _inrFormatter.format(price.round());
  }

  /// Deterministic ±3%–12% variation between stores based on product ID hash
  static StoreVariation calculateStoreVariation(String id, double basePrice) {
    final cleanBase = basePrice.roundToDouble();
    final hash = id.hashCode.abs();
    final variationPercent = 3 + (hash % 10); // 3% to 12%
    final rawDiff = (cleanBase * variationPercent / 100).roundToDouble();
    final diff = rawDiff < 50 ? 50.0 : rawDiff;

    final isPrimaryCheaper = (hash % 3) != 0;

    if (isPrimaryCheaper) {
      final competitorPrice = (cleanBase + diff).roundToDouble();
      final savings = (competitorPrice - cleanBase).roundToDouble();
      return StoreVariation(
        primaryPrice: cleanBase,
        competitorPrice: competitorPrice,
        savings: savings > 0 ? savings : diff,
        isPrimaryLowest: true,
      );
    } else {
      final competitorPrice =
          ((cleanBase - diff).clamp(99.0, double.infinity)).roundToDouble();
      final savings = (cleanBase - competitorPrice).roundToDouble();
      return StoreVariation(
        primaryPrice: cleanBase,
        competitorPrice: competitorPrice,
        savings: savings > 0 ? savings : diff,
        isPrimaryLowest: false,
      );
    }
  }
}

class StoreVariation {
  final double primaryPrice;
  final double competitorPrice;
  final double savings;
  final bool isPrimaryLowest;

  const StoreVariation({
    required this.primaryPrice,
    required this.competitorPrice,
    required this.savings,
    required this.isPrimaryLowest,
  });
}
