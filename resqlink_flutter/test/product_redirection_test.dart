import 'package:flutter_test/flutter_test.dart';
import 'package:resqlink_flutter/deallens/models/product_models.dart';

void main() {
  group('Exact Product URL Validation Tests', () {
    test('Verifies exact product URLs across 4 different retailers', () {
      // 1. Amazon exact product URL
      const amazonExactUrl =
          'https://www.amazon.in/dp/B0BDK62PDX?tag=deallens-21';
      expect(Product.isValidProductUrl(amazonExactUrl), isTrue);

      // 2. Flipkart exact product URL
      const flipkartExactUrl =
          'https://www.flipkart.com/apple-iphone-14-starlight-128-gb/p/itm12345';
      expect(Product.isValidProductUrl(flipkartExactUrl), isTrue);

      // 3. Meesho exact product URL
      const meeshoExactUrl = 'https://www.meesho.com/s/p/4abc1';
      expect(Product.isValidProductUrl(meeshoExactUrl), isTrue);

      // 4. Croma exact product URL
      const cromaExactUrl =
          'https://www.croma.com/apple-iphone-14-128gb/p/261933';
      expect(Product.isValidProductUrl(cromaExactUrl), isTrue);
    });

    test(
      'Rejects search results URLs for Buy Now (Never redirect to search)',
      () {
        // Amazon search query URLs
        expect(
          Product.isValidProductUrl('https://www.amazon.in/s?k=iphone+14'),
          isFalse,
        );
        expect(
          Product.isValidProductUrl('https://www.amazon.in/s?k=Heshe+Bag'),
          isFalse,
        );
        expect(
          Product.isValidProductUrl(
            'https://www.amazon.in/s?field-keywords=phone',
          ),
          isFalse,
        );

        // Flipkart search query URLs
        expect(
          Product.isValidProductUrl('https://www.flipkart.com/search?q=iphone'),
          isFalse,
        );

        // Meesho search query URLs
        expect(
          Product.isValidProductUrl('https://www.meesho.com/search?q=bag'),
          isFalse,
        );
      },
    );

    test('Rejects missing and empty URLs gracefully', () {
      expect(Product.isValidProductUrl(null), isFalse);
      expect(Product.isValidProductUrl(''), isFalse);
      expect(Product.isValidProductUrl('   '), isFalse);
    });

    test('Rejects invalid schemes and malformed strings', () {
      expect(Product.isValidProductUrl('javascript:void(0)'), isFalse);
      expect(Product.isValidProductUrl('ftp://amazon.in/dp/123'), isFalse);
      expect(Product.isValidProductUrl('not-a-valid-url'), isFalse);
    });
  });

  group('RetailerOffer Data Model Compliance (Requirement 2)', () {
    test('Stores all required fields for retailer offers', () {
      final now = DateTime.now();
      final offer = RetailerOffer(
        productId: 'prod_123',
        productName: 'Sony WH-1000XM5 Headphones',
        storeName: 'Amazon',
        storeLabel: 'Amazon.in',
        price: 26990.0,
        currency: 'INR',
        url: 'https://www.amazon.in/dp/B09XS7JWHH',
        imageUrl: 'https://images.amazon.com/sony.jpg',
        lastUpdated: now,
      );

      expect(offer.productId, equals('prod_123'));
      expect(offer.productName, equals('Sony WH-1000XM5 Headphones'));
      expect(offer.retailerName, equals('Amazon.in'));
      expect(offer.price, equals(26990.0));
      expect(offer.currency, equals('INR'));
      expect(offer.productUrl, equals('https://www.amazon.in/dp/B09XS7JWHH'));
      expect(offer.imageUrl, equals('https://images.amazon.com/sony.jpg'));
      expect(offer.lastUpdated, equals(now));
      expect(offer.hasExactProductUrl, isTrue);

      // Verify JSON serialization round-trip
      final json = offer.toJson();
      final fromJson = RetailerOffer.fromJson(json);
      expect(fromJson.productId, equals('prod_123'));
      expect(fromJson.productName, equals('Sony WH-1000XM5 Headphones'));
      expect(fromJson.retailerName, equals('Amazon.in'));
      expect(fromJson.price, equals(26990.0));
      expect(fromJson.currency, equals('INR'));
      expect(
        fromJson.productUrl,
        equals('https://www.amazon.in/dp/B09XS7JWHH'),
      );
      expect(fromJson.hasExactProductUrl, isTrue);
    });
  });

  group('No Fake Data / Demo Product Link Behavior', () {
    test('Demo products do not have verified product URLs', () {
      final dummyJsonProduct = Product.fromDummyJson({
        'id': 1,
        'title': "Heshe Women's Leather Bag",
        'price': 55.0,
        'category': 'womens-bags',
        'rating': 4.5,
      });

      // Must be null and NOT a search results link
      expect(dummyJsonProduct.buyUrl, isNull);
      expect(dummyJsonProduct.hasExactProductUrl, isFalse);
      expect(dummyJsonProduct.offers.first.productUrl, isNull);
      expect(dummyJsonProduct.offers.first.hasExactProductUrl, isFalse);
    });

    test('Live SerpApi products store and verify exact product links', () {
      final serpProduct = Product.fromSerpApi({
        'product_id': 'serp_12345',
        'title': 'Apple iPhone 15 (128 GB) - Blue',
        'source': 'Amazon.in',
        'price': '₹65,999',
        'extracted_price': 65999,
        'link': 'https://www.amazon.in/dp/B0CHX1W1XY',
        'rating': 4.6,
      }, 'smartphones');

      expect(serpProduct.buyUrl, equals('https://www.amazon.in/dp/B0CHX1W1XY'));
      expect(serpProduct.hasExactProductUrl, isTrue);
      expect(serpProduct.offers.first.hasExactProductUrl, isTrue);
      expect(serpProduct.storeName, equals('Amazon'));
    });
  });

  group('Requirement 1 & 4: Retailer Mapping and Link Type Classification', () {
    test('Classifies direct retailer URLs accurately', () {
      expect(
        Product.classifyUrl('https://www.amazon.in/dp/B0BDK62PDX'),
        equals(ProductUrlType.retailer),
      );
      expect(
        Product.classifyUrl(
          'https://www.flipkart.com/apple-iphone-15/p/itm123',
        ),
        equals(ProductUrlType.retailer),
      );
      expect(
        Product.classifyUrl('https://www.croma.com/phone/p/261933'),
        equals(ProductUrlType.retailer),
      );
    });

    test('Classifies Google Shopping product links accurately', () {
      const googleShoppingUrl =
          'https://www.google.com/search?ibp=oshop&q=Honor+Robot+Phone&prds=catalogid:14754391832034440726,productid:16283766052137347286,pvt:hg&hl=en&gl=in&udm=28';
      expect(
        Product.classifyUrl(googleShoppingUrl),
        equals(ProductUrlType.googleShopping),
      );
      expect(Product.isGoogleShoppingUrl(googleShoppingUrl), isTrue);
      expect(Product.isDirectRetailerUrl(googleShoppingUrl), isFalse);
      expect(Product.isUsableProductUrl(googleShoppingUrl), isTrue);
    });

    test('Rejects invalid URLs and generic search queries', () {
      expect(
        Product.classifyUrl('https://www.amazon.in/s?k=pixel'),
        equals(ProductUrlType.none),
      );
      expect(
        Product.classifyUrl('https://www.flipkart.com/search?q=pixel'),
        equals(ProductUrlType.none),
      );
      expect(Product.classifyUrl(''), equals(ProductUrlType.none));
      expect(Product.classifyUrl(null), equals(ProductUrlType.none));
    });
  });

  group('Requirement 2 & 6: Honor Robot Phone SerpApi Raw Response Parsing', () {
    test('Parses raw SerpApi Honor Robot Phone without defaulting to Amazon', () {
      final rawHonorJson = {
        'position': 1,
        'title':
            'Honor Robot Phone 5G Smartphone (Silver White, 16GB RAM, 1TB Storage)',
        'product_id': '4537572211759476636',
        'product_link':
            'https://www.google.com/search?ibp=oshop&q=Honor+Robot+Phone+5G+Smartphone&prds=productid:4537572211759476636,headlineOfferDocid:4537572211759476636,pvt:hg&hl=en&gl=in&udm=28',
        'source': 'The Bank of Electronics',
        'source_icon':
            'https://serpapi.com/searches/6ace707db13aa717cbc3d4e0/images/I_ql5s20pQpc1wdzg_XeFxWtsiezQL3sNJBHaIskwuI.png',
        'price': '₹2,64,990',
        'extracted_price': 264990,
        'rating': 5.0,
        'reviews': 2,
        'thumbnail':
            'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRESD',
      };

      final product = Product.fromSerpApi(rawHonorJson, 'smartphones');

      // 1. Retailer name must match source, NOT Amazon
      expect(product.storeName, equals('The Bank of Electronics'));
      expect(product.storeLabel, equals('The Bank of Electronics'));
      expect(product.storeName, isNot(equals('Amazon')));

      // 2. Icon URL from SerpApi must be preserved
      expect(
        product.storeIconUrl,
        equals(
          'https://serpapi.com/searches/6ace707db13aa717cbc3d4e0/images/I_ql5s20pQpc1wdzg_XeFxWtsiezQL3sNJBHaIskwuI.png',
        ),
      );
      expect(product.offers.first.iconUrl, equals(product.storeIconUrl));

      // 3. Price must be correctly parsed
      expect(product.price, equals(264990.0));
      expect(product.hasValidPrice, isTrue);

      // 4. Rating must be 5.0 (real API value)
      expect(product.rating, equals(5.0));
      expect(product.hasValidRating, isTrue);

      // 5. Must NOT claim lowest price without comparable offers
      expect(product.offers.first.isLowest, isFalse);

      // 6. Link must be classified as Google Shopping
      expect(product.urlType, equals(ProductUrlType.googleShopping));
      expect(product.isGoogleShoppingPage, isTrue);
      expect(product.hasUsableUrl, isTrue);
      expect(product.hasExactProductUrl, isFalse);
    });

    test('Hides ratings when API does not provide a rating', () {
      final noRatingJson = {
        'position': 5,
        'title': 'Poco M7 5G',
        'source': 'Reliance Digital',
        'price': '₹12,499',
        'extracted_price': 12499,
        // no rating field in API response
      };

      final product = Product.fromSerpApi(noRatingJson, 'smartphones');

      expect(product.rating, equals(0.0));
      expect(product.hasValidRating, isFalse); // Rating is hidden!
      expect(product.storeName, equals('Reliance Digital'));
    });

    test(
      'Parses real SerpApi keyboard results accurately without fabrication',
      () {
        final keyboardJson = {
          'position': 1,
          'title': 'Ant Value Fkbri01 Wired Keyboard',
          'product_id': '10055565044377236080',
          'product_link':
              'https://www.google.com/search?ibp=oshop&q=keyboard&prds=catalogid:10055565044377236080,productid:1911555119355052207,pvt:hg&hl=en&gl=in&udm=28',
          'source': 'Amazon.in',
          'price': '₹199',
          'extracted_price': 199,
          'thumbnail':
              'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:sample',
        };

        final product = Product.fromSerpApi(keyboardJson, 'electronics');

        expect(product.title, equals('Ant Value Fkbri01 Wired Keyboard'));
        expect(product.price, equals(199.0));
        expect(product.hasValidPrice, isTrue);
        expect(product.rating, equals(0.0));
        expect(
          product.hasValidRating,
          isFalse,
        ); // No rating provided -> accurately hidden
        expect(product.storeName, equals('Amazon'));
        expect(product.storeLabel, equals('Amazon.in'));
        expect(product.urlType, equals(ProductUrlType.googleShopping));
        expect(product.isGoogleShoppingPage, isTrue);
        expect(product.hasUsableUrl, isTrue);
      },
    );
  });

  group('Google Shopping Redirect Resolution & Safety Tests', () {
    test('Safely unwraps destination from Google redirect URL parameter', () {
      const googleRedirectUrl =
          'https://www.google.com/url?url=https%3A%2F%2Fwww.flipkart.com%2Fapple-iphone-15-black-128-gb%2Fp%2Fitm12345&rct=j&q=&esrc=s';
      final unwrapped = Product.unwrapGoogleUrl(googleRedirectUrl);
      expect(
        unwrapped,
        equals(
          'https://www.flipkart.com/apple-iphone-15-black-128-gb/p/itm12345',
        ),
      );
      expect(Product.isDirectRetailerUrl(unwrapped), isTrue);
      expect(Product.isValidProductUrl(googleRedirectUrl), isTrue);
    });

    test('Safely unwraps q parameter from Google redirect URL', () {
      const googleQRedirect =
          'https://www.google.co.in/url?q=https://www.amazon.in/dp/B0CHX1W1XY&sa=U';
      final unwrapped = Product.unwrapGoogleUrl(googleQRedirect);
      expect(unwrapped, equals('https://www.amazon.in/dp/B0CHX1W1XY'));
      expect(Product.isValidProductUrl(googleQRedirect), isTrue);
    });

    test('Rejects dangerous and untrusted redirect schemes', () {
      expect(
        Product.isValidProductUrl('javascript:alert(document.cookie)'),
        isFalse,
      );
      expect(Product.isValidProductUrl('file:///etc/passwd'), isFalse);
      expect(
        Product.isValidProductUrl('ftp://insecure.site/file.apk'),
        isFalse,
      );
      expect(
        Product.isValidProductUrl('data:text/html,<script>evil()</script>'),
        isFalse,
      );
    });

    test('Rejects fabricated mock URLs that caused device error pages', () {
      // Mock URLs that returned Amazon 404 and Meesho blank error pages
      const fakeAmazonUrl = 'https://www.amazon.in/dp/brand_prod_0001';
      const fakeMeeshoUrl = 'https://www.meesho.com/s/p/meesho_saree_001';
      const fakeMeeshoProdUrl = 'https://www.meesho.com/s/p/meesho_prod_0001';
      const fakePlatziUrl = 'https://www.flipkart.com/p/platzi_123';

      expect(Product.isValidProductUrl(fakeAmazonUrl), isFalse);
      expect(Product.isValidProductUrl(fakeMeeshoUrl), isFalse);
      expect(Product.isValidProductUrl(fakeMeeshoProdUrl), isFalse);
      expect(Product.isValidProductUrl(fakePlatziUrl), isFalse);
    });
  });

  group('Data Integrity: Missing Prices & Empty Responses', () {
    test(
      'Handles missing price honestly with hasValidPrice = false and "Price unavailable"',
      () {
        const missingPriceProduct = Product(
          id: 'serp_noprice',
          title: 'Sony WH-CH520 Wireless Headphones',
          category: 'Headphones',
          imageUrl: 'https://images.example.com/ch520.jpg',
          price: 0.0,
          rating: 4.3,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0BS15K',
        );

        expect(missingPriceProduct.hasValidPrice, isFalse);
        expect(missingPriceProduct.priceDisplay, equals('Price unavailable'));
      },
    );

    test('Handles empty and failed SerpApi responses gracefully', () {
      final emptyJson = <String, dynamic>{
        'search_metadata': {'status': 'Success'},
        'shopping_results': [],
      };

      final results = (emptyJson['shopping_results'] as List)
          .map(
            (item) =>
                Product.fromSerpApi(item as Map<String, dynamic>, 'general'),
          )
          .toList();

      expect(results, isEmpty);
    });
  });
}
