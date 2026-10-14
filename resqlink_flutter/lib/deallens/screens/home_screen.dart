import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_models.dart';
import '../providers/products_provider.dart';
import '../providers/search_provider.dart';
import '../services/buy_service.dart';
import '../services/url_launcher_service.dart';
import '../theme/deallens_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/category_item.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_loading.dart';
import 'product_details_screen.dart';
import 'trending_screen.dart';

/// Home screen — product discovery landing page with real API data across 3 stores + SerpApi live.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final void Function(String categoryTitle)? onCategorySelect;

  const HomeScreen({
    super.key,
    this.onSearchTap,
    this.onCategorySelect,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _exploreItemCount = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductsProvider>();
      if (provider.allProducts.isEmpty && !provider.isLoading) {
        provider.fetchHomeData();
      }
    });
  }

  void _onCategoryTapped(String categoryTitle) {
    final catalog = context.read<ProductsProvider>().allProducts;
    if (widget.onCategorySelect != null) {
      widget.onCategorySelect!(categoryTitle);
    } else {
      context.read<SearchProvider>().filterByCategory(categoryTitle, catalog);
      widget.onSearchTap?.call();
    }
  }

  void _openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: product,
          onViewDeal: (url) {
            UrlLauncherService.openProductUrl(
              context: context,
              url: url ?? product.buyUrl,
              storeName: product.storeName,
            );
          },
        ),
      ),
    );
  }

  void _openTrendingAll() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TrendingScreen(
          title: 'Trending Deals',
          isBestPrices: false,
        ),
      ),
    );
  }

  void _openBestPricesAll() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TrendingScreen(
          title: 'Best Price Deals',
          isBestPrices: true,
        ),
      ),
    );
  }

  Future<void> _handleRefreshConfirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refresh Live Prices?'),
        content: const Text(
          'Uses 6 live searches to fetch the latest prices across Indian stores.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ProductsProvider>().fetchHomeData(
        forceRefresh: true,
        forceLiveReload: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();
    final activeCategories = productsProvider.activeCategories;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(
              size: 32,
              borderRadius: 8,
              showShadow: false,
            ),
            const SizedBox(width: 10),
            Text(
              'DealLens',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _handleRefreshConfirm,
            tooltip: 'Live reload (Uses 6 live searches)',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => productsProvider.fetchHomeData(forceRefresh: true),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // ── Search Bar ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: DealLensSearchBar(
                  readOnly: true,
                  onTap: widget.onSearchTap,
                ),
              ),

              // ── Top Category Chips (Strictly active categories > 0) ──
              if (activeCategories.isNotEmpty)
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeCategories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = activeCategories[index];
                      return CategoryItem(
                        category: cat,
                        onTap: () => _onCategoryTapped(cat.name),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // ── Popular Categories ───────────────────────────────
              if (activeCategories.isNotEmpty) ...[
                const SectionHeader(title: 'Popular Categories'),
                const SizedBox(height: 12),
                _buildPopularCategories(activeCategories),
                const SizedBox(height: 24),
              ],

              // ── Trending Products (Top 15 by rating) ─────────────
              SectionHeader(
                title: 'Trending Products',
                actionLabel: 'See All',
                onActionTap: _openTrendingAll,
              ),
              const SizedBox(height: 12),
              _buildTrendingSection(productsProvider),

              const SizedBox(height: 24),

              // ── Best Prices (Grouped by title/category with Save badge) ──
              SectionHeader(
                title: 'Best Prices',
                actionLabel: 'See All',
                onActionTap: _openBestPricesAll,
              ),
              const SizedBox(height: 12),
              _buildBestPricesSection(productsProvider),

              const SizedBox(height: 24),

              // ── Top Tech & Smartphones (Exact canonical prices & direct buy) ──
              if (productsProvider.topTechDeals.isNotEmpty) ...[
                SectionHeader(
                  title: 'Top Tech & Smartphones',
                  actionLabel: 'See All',
                  onActionTap: () => _onCategoryTapped('Smartphones'),
                ),
                const SizedBox(height: 12),
                _buildTechSection(productsProvider),
                const SizedBox(height: 24),
              ],

              // ── Trending Fashion & Sarees (Ethnic Wear & Accessories) ──
              if (productsProvider.topFashionDeals.isNotEmpty) ...[
                SectionHeader(
                  title: 'Trending Fashion & Sarees',
                  actionLabel: 'See All',
                  onActionTap: () => _onCategoryTapped('Fashion'),
                ),
                const SizedBox(height: 12),
                _buildFashionSection(productsProvider),
                const SizedBox(height: 24),
              ],

              // ── Explore All Deals (Responsive multi-store discovery grid) ──
              if (productsProvider.allProducts.isNotEmpty) ...[
                const SectionHeader(title: 'Explore All Deals'),
                const SizedBox(height: 12),
                _buildExploreGrid(productsProvider),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularCategories(List<ProductCategory> categories) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _PopularCategoryCard(
            title: cat.name,
            icon: cat.icon,
            countText: '${cat.count} products',
            onTap: () => _onCategoryTapped(cat.name),
          );
        },
      ),
    );
  }

  Widget _buildTrendingSection(ProductsProvider provider) {
    if (provider.isLoading && provider.allProducts.isEmpty) {
      return const HorizontalProductListSkeleton();
    }

    if (provider.errorMessage != null && provider.allProducts.isEmpty) {
      return _buildErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.fetchHomeData(forceRefresh: true),
      );
    }

    final trending = provider.trendingTop15;

    if (trending.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyStateWidget(
          icon: Icons.trending_up_rounded,
          title: 'No Data Yet',
          message: 'Trending products will appear when connected to internet.',
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: trending.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = trending[index];
          return ProductCard(
            product: product,
            onTap: () => _openDetails(product),
            onViewDeal: () => BuyService.buyProduct(context, product),
          );
        },
      ),
    );
  }

  Widget _buildBestPricesSection(ProductsProvider provider) {
    if (provider.isLoading && provider.allProducts.isEmpty) {
      return const HorizontalProductListSkeleton();
    }

    if (provider.errorMessage != null && provider.allProducts.isEmpty) {
      return _buildErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.fetchHomeData(forceRefresh: true),
      );
    }

    final deals = provider.bestPriceDealsTop15;

    if (deals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyStateWidget(
          icon: Icons.savings_outlined,
          title: 'No Data Yet',
          message: 'Best price comparisons will appear once items are loaded.',
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: deals.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = deals[index];
          return ProductCard(
            product: product,
            onTap: () => _openDetails(product),
            onViewDeal: () => BuyService.buyProduct(context, product),
          );
        },
      ),
    );
  }

  Widget _buildTechSection(ProductsProvider provider) {
    final tech = provider.topTechDeals;
    if (tech.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tech.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = tech[index];
          return ProductCard(
            product: product,
            onTap: () => _openDetails(product),
            onViewDeal: () => BuyService.buyProduct(context, product),
          );
        },
      ),
    );
  }

  Widget _buildFashionSection(ProductsProvider provider) {
    final fashion = provider.topFashionDeals;
    if (fashion.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: fashion.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = fashion[index];
          return ProductCard(
            product: product,
            onTap: () => _openDetails(product),
            onViewDeal: () => BuyService.buyProduct(context, product),
          );
        },
      ),
    );
  }

  Widget _buildExploreGrid(ProductsProvider provider) {
    final all = provider.allProducts;
    if (all.isEmpty) return const SizedBox.shrink();

    final visibleCount = _exploreItemCount.clamp(0, all.length);
    final visibleItems = all.take(visibleCount).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.58,
            ),
            itemCount: visibleItems.length,
            itemBuilder: (context, index) {
              final product = visibleItems[index];
              return ProductCard(
                product: product,
                width: double.infinity,
                onTap: () => _openDetails(product),
                onViewDeal: () => BuyService.buyProduct(context, product),
              );
            },
          ),
          if (_exploreItemCount < all.length) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _exploreItemCount =
                        (_exploreItemCount + 20).clamp(0, all.length);
                  });
                },
                icon: const Icon(Icons.expand_more_rounded),
                label: Text(
                  'Load More Products (${all.length - _exploreItemCount} more)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DealLensTheme.primaryBlue,
                  side: const BorderSide(
                    color: DealLensTheme.primaryBlue,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DealLensTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DealLensTheme.borderSubtle),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: DealLensTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _PopularCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String countText;
  final VoidCallback onTap;

  const _PopularCategoryCard({
    required this.title,
    required this.icon,
    required this.countText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DealLensTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: DealLensTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        countText,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
