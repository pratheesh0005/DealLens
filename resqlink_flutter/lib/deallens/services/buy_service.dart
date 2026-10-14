import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product_models.dart';
import '../theme/deallens_theme.dart';
import 'direct_link_service.dart';

class BuyService {
  /// Opens the exact merchant product buy now page directly.
  /// Never redirects to a store search results page.
  static Future<void> buyProduct(BuildContext context, Product product) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final shortTitle = product.title.split(' ').take(3).join(' ');

    scaffoldMessenger.showSnackBar(
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
            Expanded(
              child: Text(
                'Opening $shortTitle at ${product.priceDisplay} on ${product.storeLabel.isNotEmpty ? product.storeLabel : product.storeName}...',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: DealLensTheme.primaryBlue,
      ),
    );

    try {
      // 1. Resolve exact product buy now page
      final targetUrl = await DirectLinkService.resolve(product);

      if (targetUrl == null || targetUrl.isEmpty) {
        throw Exception('Could not resolve direct product page.');
      }

      final uri = Uri.parse(targetUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Could not open product page: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
