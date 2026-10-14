import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product_models.dart';
import '../theme/deallens_theme.dart';
import 'buy_service.dart';

class UrlLauncherService {
  static bool _isLaunching = false;

  /// Opens the exact, verified retailer product URL or Google Shopping destination.
  /// Validates URL scheme, hostname, and handles App Links with browser fallback.
  /// Does not scrape unauthorized pages or simulate retailer app clicks.
  static Future<bool> openProductUrl({
    required BuildContext context,
    required String? url,
    String? storeName,
  }) async {
    if (_isLaunching) return false;
    _isLaunching = true;

    try {
      final cleanUrl = url?.trim();
      if (cleanUrl == null || cleanUrl.isEmpty) {
        showLinkUnavailableWarning(context);
        return false;
      }

      // 1. Immediately unwrap Google redirect parameter (/url?url=... or /url?q=...)
      final effectiveUrl = Product.unwrapGoogleUrl(cleanUrl) ?? cleanUrl;

      // 2. Reject fake or mock URLs from earlier test catalogs
      final lower = effectiveUrl.toLowerCase();
      if (lower.contains('brand_prod_') ||
          lower.contains('meesho_saree_') ||
          lower.contains('dummy_') ||
          lower.contains('platzi_') ||
          lower.contains('fakestore_') ||
          lower.contains('example.com') ||
          lower.contains('localhost')) {
        showLinkUnavailableWarning(context);
        return false;
      }

      // 3. Validate URI structure and scheme
      final uri = Uri.tryParse(effectiveUrl);
      if (uri == null ||
          (!uri.isScheme('http') && !uri.isScheme('https')) ||
          uri.host.isEmpty ||
          !uri.host.contains('.')) {
        if (context.mounted) {
          _showWarning(context, 'Invalid or unsupported product link.');
        }
        return false;
      }

      // 4. Exclude generic search pages when an exact product is expected
      if (lower.contains('/s?k=') ||
          lower.contains('/search?') ||
          lower.contains('search_query=')) {
        if (context.mounted) {
          _showWarning(context, 'Direct product link unavailable.');
        }
        return false;
      }

      // 5. Diagnostic logging excluding sensitive query params/tokens
      final isDirect = Product.isDirectRetailerUrl(effectiveUrl);
      final isGoogle = Product.isGoogleShoppingUrl(effectiveUrl);
      debugPrint(
        '[UrlLauncher] Launching: ${uri.scheme}://${uri.host}${uri.path} '
        '(store: ${storeName ?? "unknown"}, directRetailer: $isDirect, googleShopping: $isGoogle)',
      );

      // 6. User feedback: honest labeling of destination
      if (context.mounted) {
        final storeLabel = (storeName != null && storeName.isNotEmpty)
            ? storeName
            : (isGoogle ? 'Google Shopping' : 'Store');
        final message = isGoogle
            ? 'Opening Google Shopping product page...'
            : 'Opening $storeLabel deal...';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: DealLensTheme.primaryBlue,
          ),
        );
      }

      // 7. Launch with LaunchMode.externalApplication to trigger Android App Links
      // (Amazon app, Flipkart app, Meesho app, etc.) when supported.
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // Fallback to system browser if external application returns false
      if (!launched) {
        final browserLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (!browserLaunched && context.mounted) {
          _showWarning(
            context,
            'Could not open retailer product page in browser.',
          );
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('[UrlLauncher] Error opening URL: $e');
      if (context.mounted) {
        _showWarning(context, 'Could not open retailer page.');
      }
      return false;
    } finally {
      _isLaunching = false;
    }
  }

  /// Opens the exact product buy page directly.
  static Future<void> openProductOrSearch({
    required BuildContext context,
    required Product product,
  }) async {
    await BuyService.buyProduct(context, product);
  }

  /// Direct product jump fallback (never redirects to a search results page)
  static Future<bool> openStoreSearch({
    required BuildContext context,
    required String productTitle,
    String? storeName,
  }) async {
    final cleanTitle = Uri.encodeComponent(productTitle.trim());
    final s = (storeName ?? '').toLowerCase();

    String searchUrl;
    if (s.contains('amazon')) {
      searchUrl =
          'https://www.google.com/search?btnI=1&q=site:amazon.in+inurl:dp+$cleanTitle';
    } else if (s.contains('flipkart')) {
      searchUrl =
          'https://www.google.com/search?btnI=1&q=site:flipkart.com+/p/+$cleanTitle';
    } else if (s.contains('meesho')) {
      searchUrl =
          'https://www.google.com/search?btnI=1&q=site:meesho.com+/p/+$cleanTitle';
    } else {
      searchUrl =
          'https://www.google.com/search?btnI=1&q=site:${Uri.encodeComponent(storeName ?? "store")}.com+$cleanTitle';
    }

    try {
      final uri = Uri.parse(searchUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      return true;
    } catch (e) {
      debugPrint('[UrlLauncher] Fallback search error: $e');
      if (context.mounted) {
        _showWarning(context, 'Could not open store search.');
      }
      return false;
    }
  }

  /// Displays the required warning when direct product link is unavailable
  static void showLinkUnavailableWarning(BuildContext context) {
    _showWarning(context, 'Direct product link unavailable');
  }

  static void _showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
