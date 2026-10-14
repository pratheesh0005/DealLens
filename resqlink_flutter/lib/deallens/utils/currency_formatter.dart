import 'price_util.dart';

class CurrencyFormatter {
  static const double usdToInrRate = 83.0;

  static double usdToInr(double usd, [String category = 'default']) =>
      PriceUtil.convertUsdToInr(usd, category);

  static String formatInr(double inrPrice) => PriceUtil.format(inrPrice);
}
