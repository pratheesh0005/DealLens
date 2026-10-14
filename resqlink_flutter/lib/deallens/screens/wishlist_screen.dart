import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_models.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/buy_service.dart';
import '../theme/deallens_theme.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loading.dart';
import 'login_screen.dart';
import 'product_details_screen.dart';

/// Wishlist screen with user-scoped Firestore DB persistence, loading, error, and retry states.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  void _openDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: product,
          onViewDeal: (url) {
            BuyService.buyProduct(context, product);
          },
        ),
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final items = wishlistProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist (${items.length})'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Clear Wishlist'),
                    content: Text(
                      wishlistProvider.isSyncedWithFirestore
                          ? 'Are you sure you want to remove all saved items from your Cloud Firestore wishlist?'
                          : 'Are you sure you want to remove all saved items from your wishlist?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          wishlistProvider.clearWishlist();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => wishlistProvider.retry(),
          child: Column(
            children: [
              // ── Firestore Sync & Auth Status Banner ──────────
              _buildStatusBanner(context, auth, wishlistProvider),

              // ── Main Content: Loading, Error, Empty, or Grid ─
              Expanded(
                child: _buildBody(context, auth, wishlistProvider, items),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    AuthProvider auth,
    WishlistProvider wishlistProvider,
  ) {
    if (auth.isAuthenticated && wishlistProvider.isSyncedWithFirestore) {
      final uid = auth.user!.uid;
      final displayId = uid.length > 8 ? '${uid.substring(0, 8)}...' : uid;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DealLensTheme.savingsGreenLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: DealLensTheme.savingsGreen.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_done_rounded,
              color: DealLensTheme.savingsGreen,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Connected to Firestore DB (users/$displayId/wishlist)',
                style: const TextStyle(
                  color: DealLensTheme.savingsGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else {
      final cid = wishlistProvider.currentUserId ?? 'Guest';
      final displayId = cid.length > 14 ? '${cid.substring(0, 14)}...' : cid;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DealLensTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DealLensTheme.borderSubtle),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_done_rounded,
              color: DealLensTheme.primaryBlue,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Firestore active ($displayId). Sign in to link across devices.',
                style: const TextStyle(
                  color: DealLensTheme.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => _openLogin(context),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DealLensTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBody(
    BuildContext context,
    AuthProvider auth,
    WishlistProvider wishlistProvider,
    List<Product> items,
  ) {
    // 1. Loading State
    if (wishlistProvider.isLoading && items.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.56,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      );
    }

    // 2. Error State with Retry
    if (wishlistProvider.status == WishlistStatus.error && items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Could Not Load Wishlist',
        message:
            wishlistProvider.errorMessage ??
            'An error occurred communicating with Cloud Firestore.',
        actionLabel: 'Retry',
        onAction: () => wishlistProvider.retry(),
      );
    }

    // 3. Empty State
    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.favorite_border_rounded,
        title: 'Your Wishlist is Empty',
        message:
            'Heart products while searching to sync them to Cloud Firestore (users/{uid}/wishlist) and monitor price drops.',
        actionLabel: !auth.isAuthenticated ? 'Sign In to Sync' : null,
        onAction: !auth.isAuthenticated ? () => _openLogin(context) : null,
      );
    }

    // 4. Populated Grid View
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.56,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        return ProductCard(
          product: product,
          onTap: () => _openDetails(context, product),
          onViewDeal: () => BuyService.buyProduct(context, product),
          trailingAction: IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: DealLensTheme.error,
              size: 20,
            ),
            onPressed: () {
              wishlistProvider.removeFromWishlist(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed "${product.title}" from wishlist'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        );
      },
    );
  }
}
