import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_models.dart';
import '../providers/wishlist_provider.dart';
import '../services/buy_service.dart';
import '../theme/deallens_theme.dart';
import '../utils/constants.dart';
import 'shimmer_loading.dart';
import 'store_logo_widget.dart';

/// Reusable product card widget with store badges, live indicator, ratings, and Buy Now button.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onViewDeal;
  final Widget? trailingAction;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onViewDeal,
    this.trailingAction,
    this.width = 160,
  });

  Color _getStoreColor(String storeName, bool isVerified) {
    if (!isVerified) return const Color(0xFF5F6368); // Generic neutral grey
    return StoreLogoWidget.getBrandColor(storeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVerified = product.isRetailerVerified;
    final badgeColor = _getStoreColor(product.storeName, isVerified);
    final wishlist = context.watch<WishlistProvider>();
    final isSaved = wishlist.isInWishlist(product.id);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: DealLensTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DealLensTheme.borderSubtle, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    height: 125,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: DealLensTheme.surfaceGrey,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: ShimmerSkeleton(
                                width: double.infinity,
                                height: 125,
                                borderRadius: 0,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Store & Live / DEMO DATA badge on the top left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StoreLogoWidget(
                                storeName: product.storeName,
                                iconUrl: product.storeIconUrl,
                                size: 14,
                                borderRadius: 3,
                                showBackground: false,
                                isCompact: true,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.storeName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (product.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 5,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Live',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (AppConstants.enableDemoData)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'DEMO DATA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Wishlist heart button on top right
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          wishlist.toggleWishlist(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isSaved
                                    ? 'Removed from Wishlist'
                                    : 'Saved to Wishlist',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: isSaved
                                ? Colors.redAccent
                                : DealLensTheme.textNavy,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.priceDisplay,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: product.hasValidPrice
                                  ? DealLensTheme.savingsGreen
                                  : DealLensTheme.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: product.hasValidPrice ? 14 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.hasValidRating) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () {
                                if (onViewDeal != null) {
                                  onViewDeal!();
                                } else {
                                  BuyService.buyProduct(context, product);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    product.urlType == ProductUrlType.retailer
                                    ? badgeColor
                                    : (product.urlType ==
                                              ProductUrlType.googleShopping
                                          ? const Color(0xFF1A73E8)
                                          : badgeColor),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (trailingAction != null) ...[
                          const SizedBox(width: 6),
                          trailingAction!,
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 36,
        color: DealLensTheme.textMuted,
      ),
    );
  }
}
