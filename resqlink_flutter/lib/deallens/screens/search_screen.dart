import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_models.dart';
import '../providers/products_provider.dart';
import '../providers/search_provider.dart';
import '../services/buy_service.dart';
import '../services/url_launcher_service.dart';
import '../theme/deallens_theme.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/store_logo_widget.dart';
import 'product_details_screen.dart';

/// Search screen with 20-item pagination, store filters, and SerpApi Google Shopping live search.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductsProvider>();
      if (provider.allProducts.isEmpty && !provider.isLoading) {
        provider.fetchHomeData();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context.read<SearchProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final productsProvider = context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Compare'),
        actions: [
          if (searchProvider.hasSearched)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded),
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                searchProvider.clear();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search text field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: DealLensSearchBar(
                controller: _searchController,
                autofocus: false,
                onChanged: (val) => searchProvider.onQueryChanged(
                  val,
                  productsProvider.allProducts,
                ),
                onSubmitted: (val) => searchProvider.submitSearch(
                  val,
                  productsProvider.allProducts,
                ),
                onClear: () {
                  _searchController.clear();
                  searchProvider.clear();
                },
              ),
            ),

            // Live Search Banner / Trigger
            if (searchProvider.currentQuery.isNotEmpty)
              _buildLiveSearchPrompt(searchProvider),

            // Filter bar (Stores + Sort)
            _buildFilterBar(searchProvider),

            // Main Results Grid with 20-item infinite scroll
            Expanded(child: _buildBody(searchProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSearchPrompt(SearchProvider provider) {
    if (provider.isLiveLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DealLensTheme.primaryBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Fetching live prices from Google Shopping India...',
              style: TextStyle(
                fontSize: 12,
                color: DealLensTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.liveSearchMessage != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DealLensTheme.savingsGreenLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: DealLensTheme.savingsGreen,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.liveSearchMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: DealLensTheme.savingsGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DealLensTheme.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DealLensTheme.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.travel_explore_rounded,
            size: 18,
            color: DealLensTheme.primaryBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Find live deals for "${provider.currentQuery}"',
              style: const TextStyle(
                fontSize: 12,
                color: DealLensTheme.textNavy,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => provider.fetchLivePrices(force: true),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DealLensTheme.primaryBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Live Search',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(SearchProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DealLensTheme.borderSubtle, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          // Store filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStoreFilterChip(
                    label: 'All Stores',
                    isSelected: provider.selectedStore == null,
                    onSelected: () => provider.setSelectedStore(null),
                  ),
                  const SizedBox(width: 6),
                  _buildStoreFilterChip(
                    label: 'Amazon',
                    storeName: 'Amazon',
                    isSelected: provider.selectedStore == 'Amazon',
                    onSelected: () => provider.setSelectedStore('Amazon'),
                  ),
                  const SizedBox(width: 6),
                  _buildStoreFilterChip(
                    label: 'Flipkart',
                    storeName: 'Flipkart',
                    isSelected: provider.selectedStore == 'Flipkart',
                    onSelected: () => provider.setSelectedStore('Flipkart'),
                  ),
                  const SizedBox(width: 6),
                  _buildStoreFilterChip(
                    label: 'Meesho',
                    storeName: 'Meesho',
                    isSelected: provider.selectedStore == 'Meesho',
                    onSelected: () => provider.setSelectedStore('Meesho'),
                  ),
                  const SizedBox(width: 6),
                  _buildStoreFilterChip(
                    label: 'Croma',
                    storeName: 'Croma',
                    isSelected: provider.selectedStore == 'Croma',
                    onSelected: () => provider.setSelectedStore('Croma'),
                  ),
                  const SizedBox(width: 6),
                  _buildStoreFilterChip(
                    label: 'Reliance',
                    storeName: 'Reliance Digital',
                    isSelected: provider.selectedStore == 'Reliance Digital',
                    onSelected: () =>
                        provider.setSelectedStore('Reliance Digital'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Sort dropdown
          PopupMenuButton<SortOption>(
            initialValue: provider.currentSort,
            onSelected: provider.setSort,
            icon: const Icon(Icons.sort_rounded, size: 20),
            itemBuilder: (context) => SortOption.values.map((option) {
              return PopupMenuItem<SortOption>(
                value: option,
                child: Row(
                  children: [
                    if (provider.currentSort == option)
                      const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: DealLensTheme.primaryBlue,
                      )
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(option.label, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    String? storeName,
  }) {
    return FilterChip(
      avatar: storeName != null
          ? StoreLogoWidget(
              storeName: storeName,
              size: 16,
              borderRadius: 4,
              showBackground: false,
              isCompact: true,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : DealLensTheme.textNavy,
      ),
      backgroundColor: DealLensTheme.surfaceCard,
      selectedColor: DealLensTheme.primaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? DealLensTheme.primaryBlue
              : DealLensTheme.borderSubtle,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _buildBody(SearchProvider provider) {
    if (provider.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.56,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      );
    }

    if (provider.errorMessage != null && provider.visibleResults.isEmpty) {
      return EmptyStateWidget(
        icon: provider.isNetworkError
            ? Icons.wifi_off_rounded
            : Icons.search_off_rounded,
        title: provider.isNetworkError
            ? 'Connection Error'
            : 'No Results Found',
        message: provider.errorMessage!,
        actionLabel: 'Retry Search',
        onAction: () {
          provider.fetchLivePrices(force: true);
        },
        secondaryActionLabel: 'Clear Search',
        onSecondaryAction: () {
          _searchController.clear();
          provider.clear();
        },
      );
    }

    if (!provider.hasSearched) {
      return const EmptyStateWidget(
        icon: Icons.search_rounded,
        title: 'Search Amazon, Flipkart & Meesho',
        message:
            'Search over 300+ live products across multiple Indian stores with real-time price comparison.',
      );
    }

    final items = provider.visibleResults;

    if (items.isEmpty) {
      if (provider.selectedStore != null && provider.allMatchedCount > 0) {
        return EmptyStateWidget(
          icon: Icons.filter_alt_off_rounded,
          title: 'No Items in ${provider.selectedStore}',
          message:
              'Found ${provider.allMatchedCount} results in other stores for "${provider.currentQuery.isNotEmpty ? provider.currentQuery : provider.selectedCategoryName}".',
          actionLabel: 'Show All Stores',
          onAction: () => provider.setSelectedStore(null),
        );
      }
      return EmptyStateWidget(
        icon: Icons.filter_alt_off_rounded,
        title: 'No Matching Items',
        message: 'Try changing your store filter or search terms.',
        actionLabel: 'Reset Filters',
        onAction: () {
          provider.setSelectedStore(null);
          provider.setSort(SortOption.relevance);
        },
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.56,
      ),
      itemCount: items.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = items[index];
        return ProductCard(
          product: product,
          onTap: () => _openDetails(product),
          onViewDeal: () => BuyService.buyProduct(context, product),
        );
      },
    );
  }
}
