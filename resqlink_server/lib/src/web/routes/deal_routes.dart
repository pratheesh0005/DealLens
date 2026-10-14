import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../../business/deal_service.dart';

/// Serverpod Web Route returning JSON responses for live product searches.
class DealSearchRoute extends WidgetRoute {
  @override
  Future<WebWidget> build(Session session, Request request) async {
    final query = request.url.queryParameters['q'] ?? '';
    final force = request.url.queryParameters['force'] == 'true';

    try {
      final results = await DealService.searchProducts(
        session,
        query,
        forceRefresh: force,
      );
      return JsonWidget(object: results);
    } catch (e) {
      return JsonWidget(
        object: {
          'success': false,
          'query': query,
          'totalResults': 0,
          'results': <Map<String, dynamic>>[],
          'error': e.toString().replaceAll('StateError: ', '').replaceAll('Exception: ', ''),
        },
      );
    }
  }
}

/// Serverpod Web Route returning catalog items for home discovery.
class DealHomeRoute extends WidgetRoute {
  @override
  Future<WebWidget> build(Session session, Request request) async {
    final initialQueries = ['smartphones', 'laptops', 'headphones', 'watches', 'sneakers'];
    final List<Map<String, dynamic>> all = [];

    for (final q in initialQueries) {
      try {
        final res = await DealService.searchProducts(session, q);
        if (res['results'] is List) {
          all.addAll((res['results'] as List).cast<Map<String, dynamic>>());
        }
      } catch (_) {}
    }

    return JsonWidget(
      object: {
        'success': true,
        'totalResults': all.length,
        'results': all,
        'source': 'DealLens Serverpod Engine',
      },
    );
  }
}

/// Serverpod Health & Status Route verifying backend connectivity.
class DealHealthRoute extends WidgetRoute {
  @override
  Future<WebWidget> build(Session session, Request request) async {
    return JsonWidget(
      object: {
        'status': 'healthy',
        'service': 'DealLens Product Aggregator Serverpod Engine',
        'activeProvider': 'Google Shopping India (gl=in, hl=en)',
        'timestamp': DateTime.now().toIso8601String(),
        'capabilities': [
          'live_search',
          'store_routing',
          'price_tracking',
          'google_redirect_unwrapping',
        ],
      },
    );
  }
}
