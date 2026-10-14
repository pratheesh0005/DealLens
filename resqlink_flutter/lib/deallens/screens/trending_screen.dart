import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_models.dart';
import '../providers/products_provider.dart';
import '../services/buy_service.dart';
import '../services/url_launcher_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

/// Full screen displaying trending deals or best price deals with infinite scroll (20 at a time).
class TrendingScreen extends StatefulWidget {
  final String title;
  final bool isBestPrices;

  const TrendingScreen({
    super.key,
    this.title = 'Trending Deals',
    this.isBestPrices = false,
  });

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  final ScrollController _scrollController = ScrollController();
  int _visibleCount = 20;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<ProductsProvider>();
      final total = widget.isBestPrices
          ? provider.allBestPrices.length
          : provider.allTrending.length;

      if (_visibleCount < total) {
        setState(() {
          _visibleCount = (_visibleCount + _pageSize).clamp(0, total);
        });
      }
    }
  }

  @override
  void dispose() {
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
    final provider = context.watch<ProductsProvider>();
    final List<Product> sourceList = widget.isBestPrices
        ? provider.allBestPrices
        : provider.allTrending;
    final displayed = sourceList.take(_visibleCount).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} (${sourceList.length})'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<ProductsProvider>().fetchHomeData(
              forceRefresh: true,
              forceLiveReload: true,
            );
          },
          child: displayed.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: EmptyStateWidget(
                        icon: widget.isBestPrices
                            ? Icons.savings_outlined
                            : Icons.trending_up_rounded,
                        title: 'No Products Found',
                        message:
                            'Connect to internet to view the top deals and price comparisons.',
                      ),
                    ),
                  ],
                )
              : GridView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.56,
                  ),
                  itemCount:
                      displayed.length +
                      (_visibleCount < sourceList.length ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= displayed.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final product = displayed[index];
                    return ProductCard(
                      product: product,
                      onTap: () => _openDetails(product),
                      onViewDeal: () => BuyService.buyProduct(context, product),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
