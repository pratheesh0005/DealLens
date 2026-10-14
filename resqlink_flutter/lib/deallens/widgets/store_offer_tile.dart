import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/buy_service.dart';
import '../services/url_launcher_service.dart';
import '../theme/deallens_theme.dart';
import '../utils/price_util.dart';
import 'store_logo_widget.dart';

class StoreOfferTile extends StatelessWidget {
  final RetailerOffer offer;
  final VoidCallback? onViewDeal;

  const StoreOfferTile({super.key, required this.offer, this.onViewDeal});

  Color _getStoreColor(String storeName) {
    return StoreLogoWidget.getBrandColor(storeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeColor = _getStoreColor(offer.storeName);

    final isRetailer = offer.urlType == ProductUrlType.retailer;
    final isGoogleShopping = offer.urlType == ProductUrlType.googleShopping;
    final isUsable = offer.hasUsableUrl;

    final buttonText = isRetailer
        ? 'Buy Now'
        : (isGoogleShopping
              ? 'View on Google Shopping'
              : 'Find on ${offer.storeName}');

    final buttonColor = isGoogleShopping ? const Color(0xFF1A73E8) : storeColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DealLensTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (offer.isLowest && offer.price > 0)
              ? DealLensTheme.savingsGreen.withValues(alpha: 0.6)
              : DealLensTheme.borderSubtle,
          width: (offer.isLowest && offer.price > 0) ? 1.5 : 0.8,
        ),
      ),
      child: Row(
        children: [
          StoreLogoWidget(
            storeName: offer.storeName,
            iconUrl: offer.iconUrl,
            size: 42,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        offer.storeLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (offer.isLowest && offer.price > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DealLensTheme.savingsGreenLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Lowest',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: DealLensTheme.savingsGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  PriceUtil.format(offer.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: DealLensTheme.savingsGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                if (onViewDeal != null) {
                  onViewDeal!();
                } else if (isUsable) {
                  UrlLauncherService.openProductUrl(
                    context: context,
                    url: offer.url,
                    storeName: offer.storeName,
                  );
                } else {
                  BuyService.buyProduct(context, offer.toProduct());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
