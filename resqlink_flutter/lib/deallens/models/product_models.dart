import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/price_util.dart';

/// App category definition with icon and category mapping.
class ProductCategory {
  final String name;
  final IconData icon;
  final String dummyJsonCategory;
  final String? fakeStoreCategory;
  final int count;

  const ProductCategory({
    required this.name,
    required this.icon,
    this.dummyJsonCategory = '',
    this.fakeStoreCategory,
    this.count = 0,
  });

  ProductCategory copyWith({int? count}) {
    return ProductCategory(
      name: name,
      icon: icon,
      dummyJsonCategory: dummyJsonCategory,
      fakeStoreCategory: fakeStoreCategory,
      count: count ?? this.count,
    );
  }
}

/// Type of product link
enum ProductUrlType {
  retailer, // Direct retailer product page (e.g. Amazon /dp/, Flipkart /p/, Croma, etc.)
  googleShopping, // Google Shopping comparison / catalog page (e.g. google.com/search?ibp=oshop... or google.com/shopping/product/...)
  none, // Missing, invalid, or search results query
}

/// Represents a retailer offer for a product comparison.
class RetailerOffer {
  final String? productId;
  final String? productName;
  final String storeName;
  final String storeLabel;
  final double price;
  final String currency;
  final String? availability;
  final DateTime? lastUpdated;
  final String? url;
  final String? imageUrl;
  final String? iconUrl;
  final bool isLowest;

  const RetailerOffer({
    this.productId,
    this.productName,
    required this.storeName,
    required this.storeLabel,
    required this.price,
    this.currency = 'INR',
    this.availability = 'In Stock',
    this.lastUpdated,
    this.url,
    this.imageUrl,
    this.iconUrl,
    this.isLowest = false,
  });

  String get retailerName => storeLabel.isNotEmpty ? storeLabel : storeName;
  String? get productUrl => url;

  ProductUrlType get urlType => Product.classifyUrl(url);
  bool get hasUsableUrl => urlType != ProductUrlType.none;
  bool get hasExactProductUrl => urlType == ProductUrlType.retailer;
  bool get isGoogleShoppingPage => urlType == ProductUrlType.googleShopping;

  RetailerOffer copyWith({
    String? productId,
    String? productName,
    String? storeName,
    String? storeLabel,
    double? price,
    String? currency,
    String? availability,
    DateTime? lastUpdated,
    String? url,
    String? imageUrl,
    String? iconUrl,
    bool? isLowest,
  }) => RetailerOffer(
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    storeName: storeName ?? this.storeName,
    storeLabel: storeLabel ?? this.storeLabel,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    availability: availability ?? this.availability,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    url: url ?? this.url,
    imageUrl: imageUrl ?? this.imageUrl,
    iconUrl: iconUrl ?? this.iconUrl,
  );

  Product toProduct({String? defaultCategory, String? defaultTitle}) => Product(
    id: productId ?? 'offer_${storeName.toLowerCase()}',
    title: productName ?? defaultTitle ?? 'Product',
    storeName: storeName,
    storeLabel: storeLabel.isNotEmpty ? storeLabel : storeName,
    price: price,
    rating: 0.0,
    category: defaultCategory ?? 'electronics',
    imageUrl: imageUrl ?? '',
    buyUrl: url,
    offers: [this],
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'storeName': storeName,
    'storeLabel': storeLabel,
    'retailerName': retailerName,
    'price': price,
    'currency': currency,
    'availability': availability,
    'lastUpdated': lastUpdated?.toIso8601String(),
    'url': url,
    'productUrl': url,
    'imageUrl': imageUrl,
    'iconUrl': iconUrl,
    'isLowest': isLowest,
  };

  factory RetailerOffer.fromJson(Map<String, dynamic> json) => RetailerOffer(
    productId: json['productId'] as String?,
    productName: json['productName'] as String?,
    storeName: json['storeName'] as String? ?? 'Online Store',
    storeLabel:
        json['storeLabel'] as String? ??
        (json['retailerName'] as String? ?? 'Online Store'),
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    currency: json['currency'] as String? ?? 'INR',
    availability: json['availability'] as String? ?? 'In Stock',
    lastUpdated: json['lastUpdated'] != null
        ? DateTime.tryParse(json['lastUpdated'] as String)
        : null,
    url: (json['productUrl'] ?? json['url']) as String?,
    imageUrl: json['imageUrl'] as String?,
    iconUrl: json['iconUrl'] as String?,
    isLowest: json['isLowest'] as bool? ?? false,
  );
}

/// Product model across all data sources + SerpApi Live Search.
class Product {
  final String id;
  final String title;
  final String? description;
  final String? brand;
  final String category;
  final String imageUrl;
  final List<String> images;
  final double price; // In INR (whole number)
  final double rating;
  final String storeName;
  final String storeLabel;
  final List<RetailerOffer> offers;
  final double? savingsInr;
  final String? matchedStore;
  final double? matchedPriceInr;
  final bool isLive;
  final String? buyUrl;
  final String? storeIconUrl;
  final DateTime? savedAt;
  final DateTime? priceFetchedAt;

  const Product({
    required this.id,
    required this.title,
    this.description,
    this.brand,
    required this.category,
    required this.imageUrl,
    this.images = const [],
    required this.price,
    required this.rating,
    required this.storeName,
    required this.storeLabel,
    this.offers = const [],
    this.savingsInr,
    this.matchedStore,
    this.matchedPriceInr,
    this.isLive = false,
    this.buyUrl,
    this.storeIconUrl,
    this.savedAt,
    this.priceFetchedAt,
  });

  Product copyWith({
    String? id,
    String? title,
    String? description,
    String? brand,
    String? category,
    String? imageUrl,
    List<String>? images,
    double? price,
    double? rating,
    String? storeName,
    String? storeLabel,
    List<RetailerOffer>? offers,
    double? savingsInr,
    String? matchedStore,
    double? matchedPriceInr,
    bool? isLive,
    String? buyUrl,
    String? storeIconUrl,
    DateTime? savedAt,
    DateTime? priceFetchedAt,
  }) => Product(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    brand: brand ?? this.brand,
    category: category ?? this.category,
    imageUrl: imageUrl ?? this.imageUrl,
    images: images ?? this.images,
    price: price ?? this.price,
    rating: rating ?? this.rating,
    storeName: storeName ?? this.storeName,
    storeLabel: storeLabel ?? this.storeLabel,
    offers: offers ?? this.offers,
    savingsInr: savingsInr ?? this.savingsInr,
    matchedStore: matchedStore ?? this.matchedStore,
    matchedPriceInr: matchedPriceInr ?? this.matchedPriceInr,
    isLive: isLive ?? this.isLive,
    buyUrl: buyUrl ?? this.buyUrl,
    storeIconUrl: storeIconUrl ?? this.storeIconUrl,
    savedAt: savedAt ?? this.savedAt,
    priceFetchedAt: priceFetchedAt ?? this.priceFetchedAt,
  );

  /// All valid, unique product images (prioritizing images list, fallback to imageUrl)
  List<String> get allImages {
    final List<String> list = [];
    for (final img in images) {
      final clean = img.trim();
      if (clean.isNotEmpty &&
          clean.startsWith('http') &&
          !list.contains(clean)) {
        list.add(clean);
      }
    }
    if (list.isEmpty && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      list.add(imageUrl.trim());
    }
    return list;
  }

  bool get isDemoData => !isLive;
  bool get hasValidPrice => price > 0;
  String get priceDisplay =>
      hasValidPrice ? PriceUtil.format(price) : 'Price unavailable';

  bool get hasValidRating => rating > 0.0;

  double? get lowestPrice => price;
  String? get retailerName => storeLabel.isNotEmpty ? storeLabel : storeName;

  /// Check if the retailer identity is verified
  bool get isRetailerVerified {
    final s = (storeLabel.isNotEmpty ? storeLabel : storeName).toLowerCase();
    return s.contains('amazon') ||
        s.contains('flipkart') ||
        s.contains('meesho') ||
        s.contains('google shopping') ||
        s.contains('myntra') ||
        s.contains('croma') ||
        s.contains('reliance digital');
  }

  /// Checks whether a URL is a direct retailer product link (not a search query, not google shopping)
  static bool isDirectRetailerUrl(String? url) {
    if (url == null) return false;
    final clean = url.trim();
    if (clean.isEmpty) return false;
    final lower = clean.toLowerCase();
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      return false;
    }

    // Prohibit search query / search results URLs
    if (lower.contains('/s?k=') ||
        lower.contains('/s?') ||
        lower.contains('/search?') ||
        lower.contains('/search/') ||
        lower.contains('search_query=') ||
        lower.contains('query=')) {
      return false;
    }

    // Prohibit fake mock IDs or templates
    if (lower.contains('brand_prod_') ||
        lower.contains('meesho_saree_') ||
        lower.contains('meesho_prod_') ||
        lower.contains('dummy_') ||
        lower.contains('platzi_') ||
        lower.contains('fakestore_') ||
        lower.contains('example.com') ||
        lower.contains('localhost')) {
      return false;
    }

    // If it's a Google domain, it's not a direct retailer URL
    if (lower.contains('google.com') ||
        lower.contains('google.co.in') ||
        lower.contains('google.co.')) {
      return false;
    }

    return true;
  }

  /// Checks whether a URL is a valid Google Shopping product page or search result
  static bool isGoogleShoppingUrl(String? url) {
    if (url == null) return false;
    final clean = url.trim();
    if (clean.isEmpty) return false;
    final lower = clean.toLowerCase();
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      return false;
    }

    final isGoogle =
        lower.contains('google.com') ||
        lower.contains('google.co.in') ||
        lower.contains('google.co.') ||
        lower.contains('googleadservices.com');
    if (!isGoogle) return false;

    // Shopping product page, immersive product, oshop catalog, shopping search, or redirect
    return lower.contains('ibp=oshop') ||
        lower.contains('/shopping') ||
        lower.contains('prds=') ||
        lower.contains('catalogid') ||
        lower.contains('productid') ||
        lower.contains('udm=28') ||
        lower.contains('tbm=shop') ||
        lower.contains('/aclk') ||
        lower.contains('/url?');
  }

  /// Extracts the direct destination retailer URL from Google redirect parameters
  /// (e.g. https://www.google.com/url?url=https://www.meesho.com/... or ?q=...)
  static String? unwrapGoogleUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final clean = rawUrl.trim();
    if (clean.isEmpty) return null;

    final uri = Uri.tryParse(clean);
    if (uri == null) return clean;

    final host = uri.host.toLowerCase();
    if (host.contains('google.') || host.contains('googleadservices.')) {
      final target =
          uri.queryParameters['url'] ??
          uri.queryParameters['q'] ??
          uri.queryParameters['adurl'];

      if (target != null && target.isNotEmpty) {
        final decoded = Uri.decodeFull(target);
        if (decoded.startsWith('http://') || decoded.startsWith('https://')) {
          final decodedUri = Uri.tryParse(decoded);
          if (decodedUri != null &&
              !decodedUri.host.toLowerCase().contains('google.')) {
            return decoded;
          }
        }
      }
    }
    return clean;
  }

  /// Classify any product URL into Retailer, Google Shopping, or None
  static ProductUrlType classifyUrl(String? url) {
    if (url == null) return ProductUrlType.none;
    final clean = url.trim();
    if (clean.isEmpty) return ProductUrlType.none;
    final unwrapped = unwrapGoogleUrl(clean);
    final lower = (unwrapped ?? clean).toLowerCase();

    // Prohibit fake mock IDs or templates immediately
    if (lower.contains('brand_prod_') ||
        lower.contains('meesho_saree_') ||
        lower.contains('meesho_prod_') ||
        lower.contains('dummy_') ||
        lower.contains('platzi_') ||
        lower.contains('fakestore_') ||
        lower.contains('example.com') ||
        lower.contains('localhost')) {
      return ProductUrlType.none;
    }

    if (isDirectRetailerUrl(unwrapped)) return ProductUrlType.retailer;
    if (isGoogleShoppingUrl(clean) || isGoogleShoppingUrl(unwrapped)) {
      return ProductUrlType.googleShopping;
    }
    // Prohibit search results URLs
    if (lower.contains('/s?k=') ||
        lower.contains('/s?') ||
        lower.contains('/search?') ||
        lower.contains('/search/') ||
        lower.contains('search_query=') ||
        lower.contains('query=')) {
      return ProductUrlType.none;
    }
    if ((lower.startsWith('http://') || lower.startsWith('https://')) &&
        !lower.contains('google.')) {
      return ProductUrlType.retailer;
    }
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return ProductUrlType.googleShopping;
    }
    return ProductUrlType.none;
  }

  /// Validates whether a URL is a direct, verified retailer product link (preserves existing contract)
  static bool isValidProductUrl(String? url) =>
      isDirectRetailerUrl(unwrapGoogleUrl(url));

  /// Validates whether a URL is usable (either direct retailer or Google Shopping)
  static bool isUsableProductUrl(String? url) =>
      classifyUrl(url) != ProductUrlType.none;

  ProductUrlType get urlType => classifyUrl(buyUrl);
  bool get hasUsableUrl => urlType != ProductUrlType.none;
  bool get hasExactProductUrl => urlType == ProductUrlType.retailer;
  bool get isGoogleShoppingPage => urlType == ProductUrlType.googleShopping;

  /// Construct from DummyJSON product (Demo Data)
  factory Product.fromDummyJson(Map<String, dynamic> json) {
    final rawUsdPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final rawCategory = json['category'] as String? ?? 'General';
    final title = json['title'] as String? ?? 'Product';
    final unifiedCat = unifyCategory(rawCategory, title: title);
    final inrPrice = PriceUtil.convertToInr(
      rawPrice: rawUsdPrice,
      category: unifiedCat,
      isLive: false,
    );
    final ratingVal = (json['rating'] as num?)?.toDouble() ?? 0.0;

    final idStr = 'dummy_${json['id']}';
    final imgUrl =
        json['thumbnail'] as String? ??
        ((json['images'] as List?)?.isNotEmpty == true
            ? json['images'][0] as String
            : '');

    final List<String> parsedImages = [];
    if (json['images'] is List) {
      for (final item in json['images'] as List) {
        if (item is String && item.trim().isNotEmpty) {
          final clean = item.trim();
          if (!parsedImages.contains(clean)) {
            parsedImages.add(clean);
          }
        }
      }
    }
    if (parsedImages.isEmpty && imgUrl.isNotEmpty) {
      parsedImages.add(imgUrl);
    }

    final primaryOffer = RetailerOffer(
      productId: idStr,
      productName: title,
      storeName: 'Amazon',
      storeLabel: 'Amazon.in',
      price: inrPrice,
      currency: 'INR',
      isLowest: false,
      url: null, // Resolved on-demand via DirectLinkService
      imageUrl: imgUrl,
      lastUpdated: DateTime.now(),
    );

    return Product(
      id: idStr,
      title: title,
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      category: unifiedCat,
      imageUrl: imgUrl,
      images: parsedImages,
      price: inrPrice,
      rating: ratingVal,
      storeName: 'Amazon',
      storeLabel: 'Amazon.in',
      offers: [primaryOffer],
      savingsInr: null,
      matchedStore: null,
      matchedPriceInr: null,
      isLive: false,
      buyUrl: null, // Resolved on-demand via DirectLinkService
    );
  }

  /// Construct from Platzi API product (Demo Data)
  factory Product.fromPlatziJson(
    Map<String, dynamic> json,
    String validImageUrl,
  ) {
    final rawUsdPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final catObj = json['category'];
    final rawCategory =
        (catObj is Map ? catObj['name'] as String? : null) ?? 'Clothes';
    final title = json['title'] as String? ?? 'Product';
    final unifiedCat = unifyCategory(rawCategory, title: title);
    final inrPrice = PriceUtil.convertToInr(
      rawPrice: rawUsdPrice,
      category: unifiedCat,
      isLive: false,
    );

    final idStr = 'platzi_${json['id']}';

    final List<String> parsedImages = [];
    if (json['images'] is List) {
      for (final item in json['images'] as List) {
        final clean = Product.extractValidPlatziImage([item]);
        if (clean.isNotEmpty && !parsedImages.contains(clean)) {
          parsedImages.add(clean);
        }
      }
    }
    if (parsedImages.isEmpty && validImageUrl.isNotEmpty) {
      parsedImages.add(validImageUrl);
    }

    final primaryOffer = RetailerOffer(
      productId: idStr,
      productName: title,
      storeName: 'Flipkart',
      storeLabel: 'Flipkart.com',
      price: inrPrice,
      currency: 'INR',
      isLowest: false,
      url: null, // Resolved on-demand via DirectLinkService
      imageUrl: validImageUrl,
      lastUpdated: DateTime.now(),
    );

    return Product(
      id: idStr,
      title: title,
      description: json['description'] as String?,
      category: unifiedCat,
      imageUrl: validImageUrl,
      images: parsedImages,
      price: inrPrice,
      rating: 0.0, // Provider does not supply ratings; do not fabricate
      storeName: 'Flipkart',
      storeLabel: 'Flipkart.com',
      offers: [primaryOffer],
      savingsInr: null,
      matchedStore: null,
      matchedPriceInr: null,
      isLive: false,
      buyUrl: null, // Resolved on-demand via DirectLinkService
    );
  }

  /// Construct from FakeStoreAPI product (Demo Data)
  factory Product.fromFakeStoreJson(Map<String, dynamic> json) {
    final rawUsdPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final rawCategory = json['category'] as String? ?? 'General';
    final title = json['title'] as String? ?? 'Product';
    final unifiedCat = unifyCategory(rawCategory, title: title);
    final inrPrice = PriceUtil.convertToInr(
      rawPrice: rawUsdPrice,
      category: unifiedCat,
      isLive: false,
    );

    final ratingMap = json['rating'] as Map<String, dynamic>?;
    final ratingVal = (ratingMap?['rate'] as num?)?.toDouble() ?? 0.0;

    final idStr = 'fakestore_${json['id']}';
    final imgUrl = json['image'] as String? ?? '';

    final primaryOffer = RetailerOffer(
      productId: idStr,
      productName: title,
      storeName: 'Meesho',
      storeLabel: 'Meesho.com',
      price: inrPrice,
      currency: 'INR',
      isLowest: false,
      url: null, // Resolved on-demand via DirectLinkService
      imageUrl: imgUrl,
      lastUpdated: DateTime.now(),
    );

    return Product(
      id: idStr,
      title: title,
      description: json['description'] as String?,
      category: unifiedCat,
      imageUrl: imgUrl,
      images: imgUrl.isNotEmpty ? [imgUrl] : const [],
      price: inrPrice,
      rating: ratingVal,
      storeName: 'Meesho',
      storeLabel: 'Meesho.com',
      offers: [primaryOffer],
      savingsInr: null,
      matchedStore: null,
      matchedPriceInr: null,
      isLive: false,
      buyUrl: null, // Resolved on-demand via DirectLinkService
    );
  }

  /// Construct from SerpApi Google Shopping item (Live Data)
  factory Product.fromSerpApi(
    Map<String, dynamic> json,
    String fallbackCategory,
  ) {
    final title = json['title'] as String? ?? 'Product';
    final rawSource = (json['source'] as String? ?? '').trim();
    final source = rawSource.isNotEmpty ? rawSource : 'Google Shopping';
    final sourceIcon = json['source_icon'] as String?;
    final rawPrice = json['extracted_price'] ?? json['price'];

    double parsedPrice = 0.0;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      final digits = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      parsedPrice = double.tryParse(digits) ?? 0.0;
    }

    final priceInr = parsedPrice > 0
        ? PriceUtil.convertToInr(
            rawPrice: parsedPrice,
            category: fallbackCategory,
            isLive: true,
          )
        : 0.0;

    // Inspect both link and product_link in the SerpApi response
    final rawLink = (json['link'] as String? ?? '').trim();
    final rawProductLink = (json['product_link'] as String? ?? '').trim();

    // Unwrap Google redirect parameters to get direct retailer destination
    final unLink = unwrapGoogleUrl(rawLink);
    final unProductLink = unwrapGoogleUrl(rawProductLink);

    // Select the best available URL: prefer direct retailer page, then Google Shopping page
    String? verifiedProductUrl;
    if (isDirectRetailerUrl(unLink)) {
      verifiedProductUrl = unLink;
    } else if (isDirectRetailerUrl(unProductLink)) {
      verifiedProductUrl = unProductLink;
    } else if (isDirectRetailerUrl(rawLink)) {
      verifiedProductUrl = rawLink;
    } else if (isDirectRetailerUrl(rawProductLink)) {
      verifiedProductUrl = rawProductLink;
    } else if (isGoogleShoppingUrl(rawProductLink)) {
      verifiedProductUrl = rawProductLink;
    } else if (isGoogleShoppingUrl(rawLink)) {
      verifiedProductUrl = rawLink;
    }

    // Fallback: If neither direct retailer nor known Google shopping pattern matched,
    // preserve any non-empty web URL provided by the API so the user can navigate to it
    if (verifiedProductUrl == null) {
      if (rawProductLink.isNotEmpty &&
          (rawProductLink.startsWith('http://') ||
              rawProductLink.startsWith('https://'))) {
        verifiedProductUrl = rawProductLink;
      } else if (rawLink.isNotEmpty &&
          (rawLink.startsWith('http://') || rawLink.startsWith('https://'))) {
        verifiedProductUrl = rawLink;
      }
    }

    // Never invent ratings: only preserve real parsed API ratings, 0.0 otherwise
    final rawRating = json['rating'];
    final double ratingVal = (rawRating is num) ? rawRating.toDouble() : 0.0;

    final thumbnail = (json['thumbnail'] as String?) ?? '';

    // Map store name accurately: do not map unknown retailers to Amazon
    final lowerSource = source.toLowerCase();
    final storeName = lowerSource.contains('flipkart')
        ? 'Flipkart'
        : (lowerSource.contains('meesho')
              ? 'Meesho'
              : (lowerSource.contains('amazon')
                    ? 'Amazon'
                    : (lowerSource.contains('croma')
                          ? 'Croma'
                          : (lowerSource.contains('reliance')
                                ? 'Reliance Digital'
                                : (lowerSource.contains('myntra')
                                      ? 'Myntra'
                                      : source)))));

    // Stable ID based on product_id or clean title hash
    final productIdVal = json['product_id'] ?? '${title.hashCode.abs()}';
    final idStr = 'serp_$productIdVal';

    final primaryOffer = RetailerOffer(
      productId: idStr,
      productName: title,
      storeName: storeName,
      storeLabel: source,
      price: priceInr,
      currency: 'INR',
      isLowest:
          false, // Single offer: cannot claim lowest without comparable offers
      url: verifiedProductUrl,
      imageUrl: thumbnail,
      iconUrl: sourceIcon,
      lastUpdated: DateTime.now(),
    );

    final List<String> parsedImages = [];
    if (thumbnail.isNotEmpty) {
      parsedImages.add(thumbnail);
    }

    final rawAdditional =
        json['additional_images'] ?? json['thumbnails'] ?? json['images'];

    if (rawAdditional is List) {
      for (final it in rawAdditional) {
        String? candidate;
        if (it is String) {
          candidate = it.trim();
        } else if (it is Map) {
          candidate =
              (it['link'] ?? it['thumbnail'] ?? it['original'] ?? it['image'])
                  as String?;
          candidate = candidate?.trim();
        }
        if (candidate != null &&
            candidate.isNotEmpty &&
            candidate.startsWith('http') &&
            !parsedImages.contains(candidate)) {
          parsedImages.add(candidate);
        }
      }
    }

    final unifiedCat = unifyCategory(fallbackCategory, title: title);

    return Product(
      id: idStr,
      title: title,
      description: 'Live verified price from $source via Google Shopping India',
      category: unifiedCat,
      imageUrl: thumbnail,
      images: parsedImages,
      price: priceInr,
      rating: ratingVal,
      storeName: storeName,
      storeLabel: source,
      offers: [primaryOffer],
      isLive: true,
      buyUrl: verifiedProductUrl,
      storeIconUrl: sourceIcon,
      priceFetchedAt: DateTime.now(),
    );
  }

  /// Helper to clean Platzi images and filter out broken/placeholder links
  static String extractValidPlatziImage(dynamic images) {
    if (images is List && images.isNotEmpty) {
      for (final item in images) {
        if (item is String) {
          final clean = item
              .replaceAll(r'["', '')
              .replaceAll(r'"]', '')
              .replaceAll(r'\"', '')
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .trim();
          if (clean.startsWith('http') &&
              !clean.contains('placeimg.com') &&
              !clean.contains('via.placeholder.com') &&
              !clean.contains('lorempixel.com')) {
            return clean;
          }
        }
      }
    }
    return '';
  }

  /// Unify all API categories into app categories
  static String unifyCategory(String rawCategory, {String? title}) {
    final c = rawCategory.toLowerCase().trim();
    final t = (title ?? '').toLowerCase().trim();

    // 1. Watches = mens-watches + womens-watches + watches
    if (c == 'mens-watches' ||
        c == 'womens-watches' ||
        c.contains('watch') ||
        t.contains('watch')) {
      return 'Watches';
    }

    // 2. Sneakers/Shoes = mens-shoes + womens-shoes + shoes + sneakers
    if (c == 'mens-shoes' ||
        c == 'womens-shoes' ||
        c.contains('shoe') ||
        c.contains('sneaker') ||
        c.contains('footwear') ||
        t.contains('shoe') ||
        t.contains('sneaker') ||
        t.contains('boot') ||
        t.contains('sandal') ||
        t.contains('loafer') ||
        t.contains('jutti') ||
        t.contains('mojari') ||
        t.contains('chappal') ||
        t.contains('heel')) {
      return 'Shoes';
    }

    // 3. Home Decor = home-decoration + furniture + kitchen-accessories
    if (c == 'home-decoration' ||
        c == 'furniture' ||
        c == 'kitchen-accessories' ||
        c.contains('home-decor') ||
        c.contains('home decor') ||
        c.contains('furniture') ||
        c.contains('kitchen') ||
        t.contains('lamp') ||
        t.contains('sofa') ||
        t.contains('chair') ||
        t.contains('cushion') ||
        t.contains('table') ||
        t.contains('plant') ||
        t.contains('clock') ||
        t.contains('bedsheet') ||
        t.contains('curtain') ||
        t.contains('mat') ||
        t.contains('rug') ||
        t.contains('light')) {
      return 'Home Decor';
    }

    // 4. Smartphones
    if (c == 'smartphones' ||
        c.contains('smartphone') ||
        c.contains('mobile-phones') ||
        t.contains('iphone') ||
        t.contains('samsung galaxy') ||
        t.contains('pixel') ||
        t.contains('redmi') ||
        t.contains('realme') ||
        t.contains('oneplus')) {
      return 'Smartphones';
    }

    // 5. Laptops
    if (c == 'laptops' ||
        c.contains('laptop') ||
        c.contains('notebook') ||
        t.contains('laptop') ||
        t.contains('macbook') ||
        t.contains('thinkpad') ||
        t.contains('chromebook')) {
      return 'Laptops';
    }

    // 6. Headphones
    if (c == 'headphones' ||
        c.contains('headphone') ||
        c.contains('mobile-accessories') ||
        t.contains('headphone') ||
        t.contains('earphone') ||
        t.contains('airpods') ||
        t.contains('earbuds') ||
        t.contains('headset') ||
        t.contains('neckband')) {
      return 'Headphones';
    }

    // 7. Mobiles / Tablets
    if (c.contains('tablets') || c.contains('mobiles') || t.contains('ipad')) {
      return 'Mobiles';
    }

    // 8. Bags
    if (c.contains('womens-bags') ||
        c.contains('bags') ||
        c.contains('bag') ||
        t.contains('backpack') ||
        t.contains('handbag') ||
        t.contains('wallet') ||
        t.contains('purse') ||
        t.contains('potli') ||
        t.contains('clutch') ||
        t.contains('tote') ||
        t.contains('sling')) {
      return 'Bags';
    }

    // 9. Beauty
    if (c.contains('beauty') ||
        c.contains('skin-care') ||
        c.contains('fragrances') ||
        t.contains('cream') ||
        t.contains('perfume') ||
        t.contains('lipstick') ||
        t.contains('serum') ||
        t.contains('shampoo') ||
        t.contains('kajal') ||
        t.contains('eyeliner') ||
        t.contains('lotion') ||
        t.contains('hair oil')) {
      return 'Beauty';
    }

    // 10. Electronics
    if (c.contains('electronics') ||
        t.contains('monitor') ||
        t.contains('keyboard') ||
        t.contains('mouse') ||
        t.contains('camera') ||
        t.contains('speaker') ||
        t.contains('tv')) {
      return 'Electronics';
    }

    // 11. Fashion
    if (c.contains('clothes') ||
        c.contains('clothing') ||
        c.contains('fashion') ||
        c.contains('ethnic') ||
        c.contains('mens-shirts') ||
        c.contains('womens-dresses') ||
        c.contains('tops') ||
        t.contains('shirt') ||
        t.contains('t-shirt') ||
        t.contains('dress') ||
        t.contains('jacket') ||
        t.contains('hoodie') ||
        t.contains('jeans') ||
        t.contains('saree') ||
        t.contains('sari') ||
        t.contains('kurti') ||
        t.contains('kurta') ||
        t.contains('lehenga') ||
        t.contains('anarkali') ||
        t.contains('dupatta') ||
        t.contains('suit') ||
        t.contains('jhumka') ||
        t.contains('jewel') ||
        t.contains('necklace') ||
        t.contains('earring') ||
        t.contains('bangle')) {
      return 'Fashion';
    }

    return 'Fashion';
  }

  /// Converts this Product into the exact Firestore Wishlist schema:
  /// users/{firebaseUid}/wishlist/{productId}
  Map<String, dynamic> toFirestoreWishlistMap() => {
    'productId': id,
    'productName': title,
    'title': title,
    'category': category,
    'imageUrl': imageUrl.isNotEmpty ? imageUrl : null,
    'images': images,
    'currentPrice': price > 0 ? price : null,
    'price': price > 0 ? price : null,
    'currency': 'INR',
    'rating': rating,
    'storeName': storeName,
    'storeLabel': storeLabel.isNotEmpty
        ? storeLabel
        : (storeName.isNotEmpty ? storeName : null),
    'retailerName': storeLabel.isNotEmpty
        ? storeLabel
        : (storeName.isNotEmpty ? storeName : 'Online Store'),
    'storeIconUrl': storeIconUrl,
    'productUrl': buyUrl ?? '',
    'buyUrl': buyUrl ?? '',
    'savedAt': FieldValue.serverTimestamp(),
    'priceFetchedAt': FieldValue.serverTimestamp(),
    'isDemoData': isDemoData,
  };

  /// Constructs a Product from a Firestore Wishlist document
  factory Product.fromFirestoreWishlist(
    Map<String, dynamic> data,
    String docId,
  ) {
    final productId = data['productId'] as String? ?? docId;
    final title =
        data['productName'] as String? ??
        (data['title'] as String? ?? 'Product');
    final category = data['category'] as String? ?? 'General';
    final imageUrl = data['imageUrl'] as String? ?? '';
    final currentPrice =
        (data['currentPrice'] as num?)?.toDouble() ??
        ((data['price'] as num?)?.toDouble() ?? 0.0);
    final rating = (data['rating'] as num?)?.toDouble() ?? 4.2;
    final retailerName =
        data['retailerName'] as String? ??
        (data['storeLabel'] as String? ??
            (data['storeName'] as String? ?? 'Online Store'));
    final storeName = data['storeName'] as String? ?? retailerName;
    final storeIcon = data['storeIconUrl'] as String?;
    final productUrl =
        data['productUrl'] as String? ?? (data['buyUrl'] as String? ?? '');
    final isDemo = data['isDemoData'] as bool? ?? false;

    final List<String> parsedImages = [];
    if (data['images'] is List) {
      for (final it in data['images'] as List) {
        if (it is String && it.isNotEmpty && !parsedImages.contains(it)) {
          parsedImages.add(it);
        }
      }
    }
    if (parsedImages.isEmpty && imageUrl.isNotEmpty) {
      parsedImages.add(imageUrl);
    }

    DateTime? savedAtTime;
    if (data['savedAt'] is Timestamp) {
      savedAtTime = (data['savedAt'] as Timestamp).toDate();
    }
    DateTime? priceFetchedAtTime;
    if (data['priceFetchedAt'] is Timestamp) {
      priceFetchedAtTime = (data['priceFetchedAt'] as Timestamp).toDate();
    }

    return Product(
      id: productId,
      title: title,
      category: category,
      imageUrl: imageUrl,
      images: parsedImages,
      price: currentPrice,
      rating: rating,
      storeName: storeName,
      storeLabel: retailerName,
      storeIconUrl: storeIcon,
      offers: [
        RetailerOffer(
          storeName: storeName,
          storeLabel: retailerName,
          price: currentPrice,
          isLowest: true,
          url: productUrl.isNotEmpty ? productUrl : null,
          iconUrl: storeIcon,
        ),
      ],
      isLive: !isDemo,
      buyUrl: productUrl.isNotEmpty ? productUrl : null,
      savedAt: savedAtTime,
      priceFetchedAt: priceFetchedAtTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'brand': brand,
    'category': category,
    'imageUrl': imageUrl,
    'images': images,
    'price': price,
    'rating': rating,
    'storeName': storeName,
    'storeLabel': storeLabel,
    'offers': offers.map((o) => o.toJson()).toList(),
    'savingsInr': savingsInr,
    'matchedStore': matchedStore,
    'matchedPriceInr': matchedPriceInr,
    'isLive': isLive,
    'buyUrl': buyUrl,
    'storeIconUrl': storeIconUrl,
    'savedAt': savedAt?.toIso8601String(),
    'priceFetchedAt': priceFetchedAt?.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    brand: json['brand'] as String?,
    category: json['category'] as String? ?? 'Fashion',
    imageUrl: json['imageUrl'] as String? ?? '',
    images:
        (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        ((json['imageUrl'] as String?)?.isNotEmpty == true
            ? [json['imageUrl'] as String]
            : const []),
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    storeName: json['storeName'] as String? ?? 'Amazon',
    storeLabel: json['storeLabel'] as String? ?? 'Amazon.in',
    offers:
        (json['offers'] as List<dynamic>?)
            ?.map((o) => RetailerOffer.fromJson(o as Map<String, dynamic>))
            .toList() ??
        const [],
    savingsInr: (json['savingsInr'] as num?)?.toDouble(),
    matchedStore: json['matchedStore'] as String?,
    matchedPriceInr: (json['matchedPriceInr'] as num?)?.toDouble(),
    isLive: json['isLive'] as bool? ?? false,
    buyUrl: json['buyUrl'] as String?,
    storeIconUrl: json['storeIconUrl'] as String?,
    savedAt: json['savedAt'] != null
        ? DateTime.tryParse(json['savedAt'] as String)
        : null,
    priceFetchedAt: json['priceFetchedAt'] != null
        ? DateTime.tryParse(json['priceFetchedAt'] as String)
        : null,
  );
}

enum SortOption {
  relevance('Relevance'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  ratingHighToLow('Highest Rated');

  final String label;
  const SortOption(this.label);
}
