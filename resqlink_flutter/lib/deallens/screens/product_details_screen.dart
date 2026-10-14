import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_models.dart';
import '../providers/wishlist_provider.dart';
import '../services/buy_service.dart';
import '../services/url_launcher_service.dart';
import '../theme/deallens_theme.dart';
import '../utils/constants.dart';
import '../utils/price_util.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/store_logo_widget.dart';
import '../widgets/store_offer_tile.dart';

/// Product details screen with Firestore Wishlist toggle and authentic product links.
class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final void Function(String? url)? onViewDeal;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onViewDeal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wishlistProvider = context.watch<WishlistProvider>();
    final isSaved = wishlistProvider.isInWishlist(product.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isSaved ? Colors.redAccent : DealLensTheme.textNavy,
            ),
            onPressed: () async {
              final ok = await wishlistProvider.toggleWishlist(product);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? (isSaved
                                ? 'Removed from Wishlist'
                                : 'Saved to Wishlist!')
                          : (wishlistProvider.errorMessage ??
                                'Could not update wishlist'),
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            tooltip: isSaved ? 'Remove from Wishlist' : 'Save to Wishlist',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DealLensTheme.bgWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Snapshot',
                      style: TextStyle(
                        fontSize: 12,
                        color: DealLensTheme.textSecondary,
                      ),
                    ),
                    Text(
                      product.priceDisplay,
                      style: TextStyle(
                        fontSize: product.hasValidPrice ? 20 : 16,
                        fontWeight: FontWeight.w800,
                        color: product.hasValidPrice
                            ? DealLensTheme.savingsGreen
                            : DealLensTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  BuyService.buyProduct(context, product);
                },
                icon: const Icon(
                  Icons.shopping_cart_checkout_rounded,
                  size: 18,
                ),
                label: Text(
                  'Buy Now on ${product.storeLabel.isNotEmpty ? product.storeLabel : product.storeName}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      product.urlType == ProductUrlType.googleShopping
                      ? const Color(0xFF1A73E8)
                      : DealLensTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // ── Product Image Gallery (Amazon-style multi-image swipe, dots, counter, zoom) ──
            ProductImageGallery(
              images: product.allImages,
            ),

            const SizedBox(height: 16),

            // ── Title, Brand, Category & DEMO / LIVE Badge ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: DealLensTheme.primaryBlue.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: DealLensTheme.primaryBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (product.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 6, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'LIVE SEARCH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (AppConstants.enableDemoData)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DEMO DATA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (product.hasValidRating)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  if (product.brand != null && product.brand!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Brand: ${product.brand}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Verified Retailer & Price Banner ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: DealLensTheme.savingsGreenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DealLensTheme.savingsGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    StoreLogoWidget(
                      storeName: product.storeName,
                      iconUrl: product.storeIconUrl,
                      size: 38,
                      borderRadius: 10,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                product.storeLabel.isNotEmpty
                                    ? product.storeLabel
                                    : product.storeName,
                                style: const TextStyle(
                                  color: DealLensTheme.savingsGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (product.isRetailerVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: DealLensTheme.savingsGreen,
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            product.priceDisplay,
                            style: TextStyle(
                              color: DealLensTheme.savingsGreen,
                              fontSize: product.hasValidPrice ? 22 : 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Verified Retailer Offers ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.offers.length > 1
                            ? 'Compare Retailer Offers (${product.offers.length})'
                            : 'Retailer Source',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      if (product.offers.length > 1 &&
                          (product.savingsInr ?? 0) > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: DealLensTheme.savingsGreenLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Save ${PriceUtil.format(product.savingsInr!)}',
                            style: const TextStyle(
                              color: DealLensTheme.savingsGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (product.offers.isNotEmpty)
                    ...product.offers.map((offer) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StoreOfferTile(
                          offer: offer,
                          onViewDeal: () {
                            if (offer.url != null &&
                                offer.hasUsableUrl &&
                                !offer.url!.contains('/search') &&
                                !offer.url!.contains('/s?k=')) {
                              UrlLauncherService.openProductUrl(
                                context: context,
                                url: offer.url,
                                storeName: offer.storeName,
                              );
                            } else {
                              BuyService.buyProduct(
                                context,
                                offer.toProduct(
                                  defaultCategory: product.category,
                                  defaultTitle: product.title,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    })
                  else
                    StoreOfferTile(
                      offer: RetailerOffer(
                        productId: product.id,
                        productName: product.title,
                        storeName: product.storeName,
                        storeLabel: product.storeLabel.isNotEmpty
                            ? product.storeLabel
                            : product.storeName,
                        price: product.price,
                        currency: 'INR',
                        isLowest: true,
                        url: product.buyUrl,
                        imageUrl: product.imageUrl,
                        iconUrl: product.storeIconUrl,
                        lastUpdated: product.priceFetchedAt ?? DateTime.now(),
                      ),
                      onViewDeal: () {
                        BuyService.buyProduct(context, product);
                      },
                    ),
                ],
              ),
            ),

            if (product.description != null &&
                product.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'About Product',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  product.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: DealLensTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
