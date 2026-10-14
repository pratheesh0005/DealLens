import '../models/product_models.dart';

/// Intelligent product deduplication and offer aggregation service for DealLens.
///
/// Ensures the same physical product across different retailers (e.g. Amazon & Flipkart)
/// appears as ONE product card in feeds while preserving all distinct retailer offers
/// inside the product's offers list.
///
/// Strictly preserves variants (storage, RAM, edition, generation, colors, pack sizes).
class ProductDeduplicationService {
  /// Deduplicate a list of products, grouping multiple retailer offers under a canonical product card.
  static List<Product> deduplicate(
    List<Product> products, {
    bool preserveOffers = true,
  }) {
    if (products.isEmpty) return [];

    final List<Product> resultList = [];
    final Map<String, int> urlToIndex = {};
    final Map<String, int> idToIndex = {};
    final Map<String, int> semanticToIndex = {};

    for (final incoming in products) {
      final urlKey = _extractCanonicalUrlKey(incoming.buyUrl);
      final idKey = incoming.id.trim().isNotEmpty
          ? 'id_${incoming.id.trim()}'
          : null;
      final semanticKey = getDeduplicationKey(incoming);

      int? matchedIndex;
      if (urlKey != null && urlToIndex.containsKey(urlKey)) {
        matchedIndex = urlToIndex[urlKey];
      } else if (idKey != null && idToIndex.containsKey(idKey)) {
        matchedIndex = idToIndex[idKey];
      } else if (semanticToIndex.containsKey(semanticKey)) {
        matchedIndex = semanticToIndex[semanticKey];
      }

      if (matchedIndex != null) {
        final existing = resultList[matchedIndex];
        if (preserveOffers) {
          final merged = mergeProducts(existing, incoming);
          resultList[matchedIndex] = merged;

          // Register keys from merged offers
          if (urlKey != null) urlToIndex[urlKey] = matchedIndex;
          if (idKey != null) idToIndex[idKey] = matchedIndex;
          semanticToIndex[semanticKey] = matchedIndex;

          for (final offer in merged.offers) {
            final oUrlKey = _extractCanonicalUrlKey(offer.url);
            if (oUrlKey != null) urlToIndex[oUrlKey] = matchedIndex;
          }
        } else {
          if (incoming.price > 0 &&
              (existing.price == 0 || incoming.price < existing.price)) {
            resultList[matchedIndex] = incoming;
          }
        }
      } else {
        final initial = _ensureSelfOffer(incoming);
        final newIndex = resultList.length;
        resultList.add(initial);

        if (urlKey != null) urlToIndex[urlKey] = newIndex;
        if (idKey != null) idToIndex[idKey] = newIndex;
        semanticToIndex[semanticKey] = newIndex;

        for (final offer in initial.offers) {
          final oUrlKey = _extractCanonicalUrlKey(offer.url);
          if (oUrlKey != null) urlToIndex[oUrlKey] = newIndex;
        }
      }
    }

    return resultList;
  }

  /// Ensure a product's primary offer is present in its `offers` list
  static Product _ensureSelfOffer(Product p) {
    if (p.offers.isNotEmpty) {
      return p;
    }
    final selfOffer = RetailerOffer(
      productId: p.id,
      productName: p.title,
      storeName: p.storeName,
      storeLabel: p.storeLabel.isNotEmpty ? p.storeLabel : p.storeName,
      price: p.price,
      currency: 'INR',
      isLowest: true,
      url: p.buyUrl,
      imageUrl: p.imageUrl,
      iconUrl: p.storeIconUrl,
      lastUpdated: p.priceFetchedAt ?? DateTime.now(),
    );
    return p.copyWith(offers: [selfOffer]);
  }

  /// Merge two products representing the same physical product, combining their retailer offers.
  static Product mergeProducts(Product existing, Product incoming) {
    final existingWithSelf = _ensureSelfOffer(existing);
    final incomingWithSelf = _ensureSelfOffer(incoming);

    // 1. Combine and deduplicate retailer offers
    final Map<String, RetailerOffer> offerMap = {};

    for (final offer in [
      ...existingWithSelf.offers,
      ...incomingWithSelf.offers,
    ]) {
      final storeKey = _normalizeStoreName(offer.storeName);
      if (offerMap.containsKey(storeKey)) {
        final currentOffer = offerMap[storeKey]!;
        final isBetterPrice =
            offer.price > 0 &&
            (currentOffer.price == 0 || offer.price < currentOffer.price);
        final isBetterLink =
            offer.hasExactProductUrl && !currentOffer.hasExactProductUrl;

        if (isBetterPrice ||
            (offer.price == currentOffer.price && isBetterLink)) {
          offerMap[storeKey] = offer;
        }
      } else {
        offerMap[storeKey] = offer;
      }
    }

    final List<RetailerOffer> combinedOffers = offerMap.values.toList();

    // 2. Sort offers by price ascending (0-prices at end)
    combinedOffers.sort((a, b) {
      if (a.price > 0 && b.price <= 0) return -1;
      if (a.price <= 0 && b.price > 0) return 1;
      return a.price.compareTo(b.price);
    });

    // 3. Mark lowest price offer
    final validPrices = combinedOffers.where((o) => o.price > 0).toList();
    final lowestPrice = validPrices.isNotEmpty ? validPrices.first.price : 0.0;
    final highestPrice = validPrices.isNotEmpty ? validPrices.last.price : 0.0;

    final updatedOffers = combinedOffers.map((o) {
      final isLowest =
          (o.price > 0 && o.price == lowestPrice && validPrices.length > 1);
      return o.copyWith(isLowest: isLowest);
    }).toList();

    // 4. Calculate real savings between verified retailers
    final double realSavings = (highestPrice - lowestPrice > 0)
        ? (highestPrice - lowestPrice).roundToDouble()
        : 0.0;

    final matchedStore = (realSavings > 0) ? validPrices.last.storeName : null;
    final matchedPrice = (realSavings > 0) ? highestPrice : null;

    // 5. Select best representative product attributes
    final bestRating = existing.rating > incoming.rating
        ? existing.rating
        : incoming.rating;

    final bestTitle = (existing.title.length >= incoming.title.length)
        ? existing.title
        : incoming.title;

    final List<String> mergedImages = [];
    for (final img in [...existing.allImages, ...incoming.allImages]) {
      if (!mergedImages.contains(img)) {
        mergedImages.add(img);
      }
    }

    // Lead offer is lowest valid offer
    final leadOffer = validPrices.isNotEmpty
        ? validPrices.first
        : combinedOffers.first;

    // Prefer more specific category (e.g. Smartphones over Electronics)
    final resolvedCategory =
        (existing.category.toLowerCase() == 'electronics' &&
            incoming.category.toLowerCase() != 'electronics')
        ? incoming.category
        : existing.category;

    return existing.copyWith(
      title: bestTitle,
      category: resolvedCategory,
      price: lowestPrice > 0 ? lowestPrice : existing.price,
      rating: bestRating,
      storeName: leadOffer.storeName,
      storeLabel: leadOffer.storeLabel,
      buyUrl: leadOffer.url ?? existing.buyUrl,
      storeIconUrl: leadOffer.iconUrl ?? existing.storeIconUrl,
      offers: updatedOffers,
      savingsInr: realSavings > 0 ? realSavings : null,
      matchedStore: matchedStore,
      matchedPriceInr: matchedPrice,
      images: mergedImages,
      imageUrl: mergedImages.isNotEmpty
          ? mergedImages.first
          : existing.imageUrl,
    );
  }

  /// Generate a stable, high-confidence deduplication key for a product.
  ///
  /// Guarantees that:
  /// - Exact same product on Amazon, Flipkart, Croma, etc. share the same key.
  /// - Different storage, RAM, generation, edition, pack size, or colors have DIFFERENT keys.
  static String getDeduplicationKey(Product product) {
    // 1. Normalized Brand
    final brand = _extractBrand(product.title, product.brand);

    // 2. Extracted Variant Specs (Storage, RAM, Chip, Edition, Generation, Color, Pack)
    final specs = _extractVariantSpecs(product.title);

    // 3. Core Model Identifier
    final coreModel = _extractCoreModel(product.title, brand);

    return '${brand}_${coreModel}_$specs';
  }

  /// Extract canonical SKU identifiers from URLs (e.g. Amazon ASIN, Flipkart FSN)
  static String? _extractCanonicalUrlKey(String? url) {
    if (url == null || url.isEmpty) return null;
    final lower = url.toLowerCase();

    // Amazon ASIN: e.g. /dp/B08L5WH6NQ or /gp/product/B08L5WH6NQ
    final asinMatch = RegExp(
      r'/(?:dp|product)/([bB]0[a-zA-Z0-9]{8})',
    ).firstMatch(url);
    if (asinMatch != null) {
      return 'asin_${asinMatch.group(1)!.toUpperCase()}';
    }

    // Flipkart FSN / Item ID: e.g. /p/itm123456789 or ?pid=ITM123456789
    final fsnMatch = RegExp(
      r'/(?:p|itm)/([a-zA-Z0-9]{16}|itm[a-zA-Z0-9]+)',
    ).firstMatch(lower);
    if (fsnMatch != null) {
      return 'fsn_${fsnMatch.group(1)}';
    }

    final pidMatch = RegExp(r'[?&]pid=([a-zA-Z0-9]+)').firstMatch(url);
    if (pidMatch != null) {
      return 'fsn_${pidMatch.group(1)!.toLowerCase()}';
    }

    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.isNotEmpty && uri.path.length > 5) {
      return 'url_${uri.host.toLowerCase()}_${uri.path.toLowerCase()}';
    }

    return null;
  }

  /// Known major brands in Indian retail
  static const List<String> _knownBrands = [
    'apple',
    'sony',
    'samsung',
    'dell',
    'hp',
    'lenovo',
    'asus',
    'acer',
    'logitech',
    'nike',
    'adidas',
    'puma',
    'boat',
    'noise',
    'fastrack',
    'titan',
    'casio',
    'oneplus',
    'xiaomi',
    'redmi',
    'realme',
    'motorola',
    'oppo',
    'vivo',
    'google',
    'microsoft',
    'intel',
    'amd',
    'canon',
    'nikon',
    'jbl',
    'bose',
    'sennheiser',
    'marshall',
    'fossil',
    'wildcraft',
    'skybags',
    'american tourister',
  ];

  /// Extract and normalize brand name
  static String _extractBrand(String title, String? brand) {
    if (brand != null && brand.trim().isNotEmpty) {
      final b = brand.toLowerCase().trim();
      if (b != 'generic' && b != 'general' && b != 'brand') {
        return b;
      }
    }

    final lowerTitle = title.toLowerCase();
    for (final b in _knownBrands) {
      if (lowerTitle.startsWith(b) ||
          lowerTitle.contains(' $b ') ||
          lowerTitle.contains('$b-')) {
        return b;
      }
    }

    // Fallback: first word of title
    final firstWord = lowerTitle
        .split(RegExp(r'[^a-z0-9]'))
        .firstWhere(
          (w) => w.length > 2,
          orElse: () => 'unknown',
        );
    return firstWord;
  }

  /// Extract meaningful specification tokens (storage, RAM, generation, edition, pack, color)
  /// to prevent merging different variants
  static String _extractVariantSpecs(String title) {
    final lower = title.toLowerCase();
    final List<String> specTokens = [];

    // 1. Storage: e.g. 64GB, 128GB, 256GB, 512GB, 1TB, 2TB
    final storageMatch = RegExp(
      r'\b(64|128|256|512)\s*(?:gb|gigabytes)\b',
    ).firstMatch(lower);
    if (storageMatch != null) {
      specTokens.add('storage:${storageMatch.group(1)}gb');
    } else {
      final tbMatch = RegExp(r'\b(1|2)\s*(?:tb|terabytes)\b').firstMatch(lower);
      if (tbMatch != null) {
        specTokens.add('storage:${tbMatch.group(1)}tb');
      }
    }

    // 2. RAM: e.g. 4GB RAM, 6GB RAM, 8GB RAM, 12GB RAM, 16GB RAM, etc.
    final ramMatch = RegExp(
      r'\b(4|6|8|12|16|18|24|32|36|64)\s*(?:gb)?\s*(?:ram|memory)\b',
    ).firstMatch(lower);
    if (ramMatch != null) {
      specTokens.add('ram:${ramMatch.group(1)}gb');
    }

    // 3. Chip / Processor generation: M1, M2, M3, M4, Gen 1, 9th Gen, 10th Gen, etc.
    final mChipMatch = RegExp(
      r'\b(m1|m2|m3|m4)(?:\s*(?:pro|max|ultra))?\b',
    ).firstMatch(lower);
    if (mChipMatch != null) {
      specTokens.add('chip:${mChipMatch.group(0)!.replaceAll(' ', '')}');
    }

    final genMatch = RegExp(
      r'\b(\d+)(?:st|nd|rd|th)?\s*(?:gen|generation)\b',
    ).firstMatch(lower);
    if (genMatch != null) {
      specTokens.add('gen:${genMatch.group(1)}');
    }

    // 4. Product Editions / Form Factors
    if (lower.contains('slim')) specTokens.add('edition:slim');
    if (lower.contains('digital edition') || lower.contains('digital slim')) {
      specTokens.add('edition:digital');
    } else if (lower.contains('disc edition') ||
        lower.contains('standard disc')) {
      specTokens.add('edition:disc');
    }

    if (lower.contains('ultra')) {
      specTokens.add('edition:ultra');
    } else if (lower.contains('pro max')) {
      specTokens.add('edition:promax');
    } else if (lower.contains('pro')) {
      specTokens.add('edition:pro');
    } else if (lower.contains('plus') || lower.contains('+')) {
      specTokens.add('edition:plus');
    }

    if (lower.contains('mini')) specTokens.add('edition:mini');
    if (lower.contains('lite')) specTokens.add('edition:lite');

    // 5. Pack size / Quantity
    final packMatch = RegExp(r'\bpack\s*of\s*(\d+)\b').firstMatch(lower);
    if (packMatch != null) {
      specTokens.add('pack:${packMatch.group(1)}');
    }

    final volumeMatch = RegExp(r'\b(\d+)\s*(ml|l|kg|g)\b').firstMatch(lower);
    if (volumeMatch != null) {
      specTokens.add('size:${volumeMatch.group(1)}${volumeMatch.group(2)}');
    }

    // 6. Distinctive colors (when specified in parentheses, dashes, or end of title)
    const colorList = [
      'natural titanium',
      'blue titanium',
      'black titanium',
      'white titanium',
      'midnight',
      'starlight',
      'space gray',
      'space grey',
      'rose gold',
      'titanium gray',
      'titanium grey',
      'graphite',
      'mint',
      'lavender',
      'silver',
      'gold',
      'black',
      'white',
      'blue',
      'green',
      'red',
      'yellow',
    ];

    for (final c in colorList) {
      if (lower.contains(c)) {
        specTokens.add('color:${c.replaceAll(' ', '')}');
        break; // Match the most specific color
      }
    }

    specTokens.sort();
    return specTokens.join('|');
  }

  /// Extract core model name from title, stripping noise, marketing, and stop words
  static String _extractCoreModel(String title, String brand) {
    var s = title.toLowerCase();

    // Normalize known model synonyms
    s = s.replaceAll('ps5', 'playstation 5');

    // Remove retailer advertising text
    s = s.replaceAll(
      RegExp(
        r'(?:on|at)\s*(?:amazon|flipkart|meesho|croma|reliance|myntra).*$',
      ),
      '',
    );
    s = s.replaceAll(
      RegExp(r'^(?:amazon|flipkart|meesho|croma)\s*[:\-]\s*'),
      '',
    );

    // Remove marketing and non-identifying noise phrases
    final marketingPhrases = [
      'best seller',
      'trending now',
      'hot deal',
      'deal of the day',
      'limited time deal',
      'official store',
      'genuine',
      'original',
      '100% original',
      'free delivery',
      'fast delivery',
      'top rated',
      'brand new',
      'latest model',
      'in stock',
      'buy online',
      'special offer',
      'special price',
      'exclusive',
      'sale',
      'console',
      'laptop',
      'smartphone',
      'mobile',
      'phone',
      'running shoes',
      'shoes',
      'truly wireless',
      'wireless',
      'bluetooth',
      'tws',
      'in ear',
      'earbuds',
      'earphones',
      'headphones',
      'edition',
      '5g',
      '4g',
      'lte',
      'wifi',
      'wi fi',
    ];

    for (final phrase in marketingPhrases) {
      s = s.replaceAll(phrase, ' ');
    }

    // Remove specs already captured in variant fingerprint
    s = s.replaceAll(RegExp(r'\b\d+\s*(?:gb|tb|mb|ram|ssd)\b'), ' ');
    s = s.replaceAll(RegExp(r'\b(m1|m2|m3|m4)\b'), ' ');
    s = s.replaceAll(
      RegExp(r'\b\d+(?:st|nd|rd|th)?\s*(?:gen|generation)\b'),
      ' ',
    );
    s = s.replaceAll(
      RegExp(r'\b(slim|digital|disc|ultra|pro max|pro|plus|mini|lite)\b'),
      ' ',
    );

    // Strip punctuation and split into clean words
    s = s.replaceAll(RegExp(r'[^\w\s]'), ' ');

    const stopWords = {
      'in',
      'on',
      'at',
      'for',
      'with',
      'and',
      'the',
      'a',
      'an',
      'to',
      'of',
      'by',
      'chip',
      'storage',
      'memory',
    };

    final words = s
        .split(RegExp(r'\s+'))
        .where(
          (w) =>
              w.isNotEmpty &&
              w.length > 1 &&
              w != brand &&
              !stopWords.contains(w),
        )
        .toList();

    return words.take(4).join('_');
  }

  /// Normalize store name for offer grouping
  static String _normalizeStoreName(String rawStore) {
    final lower = rawStore.toLowerCase().trim();
    if (lower.contains('amazon')) return 'amazon';
    if (lower.contains('flipkart')) return 'flipkart';
    if (lower.contains('meesho')) return 'meesho';
    if (lower.contains('croma')) return 'croma';
    if (lower.contains('reliance')) return 'reliance';
    if (lower.contains('myntra')) return 'myntra';
    return lower;
  }
}
