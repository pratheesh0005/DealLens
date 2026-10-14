import 'package:flutter_test/flutter_test.dart';
import 'package:resqlink_flutter/deallens/models/product_models.dart';
import 'package:resqlink_flutter/deallens/services/product_deduplication_service.dart';

void main() {
  group('Product Deduplication & Multi-Retailer Offer Aggregation Tests', () {
    // 1. Identical products returned twice
    test('1. Identical products returned twice are deduplicated into one', () {
      const p1 = Product(
        id: 'serp_101',
        title: 'Sony PlayStation 5 Console (Slim Edition)',
        category: 'Electronics',
        imageUrl: 'https://images.example.com/ps5.jpg',
        price: 54990.0,
        rating: 4.8,
        storeName: 'Amazon',
        storeLabel: 'Amazon.in',
        buyUrl: 'https://www.amazon.in/dp/B0CL5P3Q1V',
      );

      const p2 = Product(
        id: 'serp_101',
        title: 'Sony PlayStation 5 Console (Slim Edition)',
        category: 'Electronics',
        imageUrl: 'https://images.example.com/ps5.jpg',
        price: 54990.0,
        rating: 4.8,
        storeName: 'Amazon',
        storeLabel: 'Amazon.in',
        buyUrl: 'https://www.amazon.in/dp/B0CL5P3Q1V',
      );

      final result = ProductDeduplicationService.deduplicate([p1, p2]);

      expect(result.length, equals(1));
      expect(
        result.first.title,
        equals('Sony PlayStation 5 Console (Slim Edition)'),
      );
      expect(result.first.offers.length, equals(1));
    });

    // 2. The same product from Amazon and Flipkart
    test(
      '2. The same product from Amazon and Flipkart merges into one card with both offers',
      () {
        const amazonP5 = Product(
          id: 'amz_ps5',
          title: 'Sony PlayStation 5 Console (Slim Edition)',
          category: 'Electronics',
          imageUrl: 'https://images.example.com/ps5_amz.jpg',
          price: 54990.0,
          rating: 4.8,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0CL5P3Q1V',
        );

        const flipkartP5 = Product(
          id: 'fk_ps5',
          title: 'Sony PlayStation 5 Slim Console',
          category: 'Electronics',
          imageUrl: 'https://images.example.com/ps5_fk.jpg',
          price: 53990.0,
          rating: 4.7,
          storeName: 'Flipkart',
          storeLabel: 'Flipkart.com',
          buyUrl: 'https://www.flipkart.com/p/itmps5slim123',
        );

        final result = ProductDeduplicationService.deduplicate([
          amazonP5,
          flipkartP5,
        ]);

        expect(result.length, equals(1));
        final merged = result.first;

        // Card displays lowest price (Flipkart: 53990)
        expect(merged.price, equals(53990.0));
        expect(merged.storeName, equals('Flipkart'));

        // Preserves both retailer offers inside offers list
        expect(merged.offers.length, equals(2));
        final stores = merged.offers.map((o) => o.storeName).toSet();
        expect(stores, containsAll(['Amazon', 'Flipkart']));

        // Lowest offer is marked
        final lowestOffer = merged.offers.firstWhere((o) => o.isLowest);
        expect(lowestOffer.storeName, equals('Flipkart'));
        expect(lowestOffer.price, equals(53990.0));
      },
    );

    // 3. Multiple valid offers grouped under one product with real savings
    test(
      '3. Multiple valid offers grouped under one product with verified savings',
      () {
        const pAmz = Product(
          id: 'ip15_amz',
          title: 'Apple iPhone 15 Pro (128 GB) - Natural Titanium',
          category: 'Smartphones',
          imageUrl: 'https://images.example.com/ip15.jpg',
          price: 134900.0,
          rating: 4.7,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0CHX1W1XY',
        );

        const pFk = Product(
          id: 'ip15_fk',
          title: 'Apple iPhone 15 Pro 128 GB Natural Titanium',
          category: 'Smartphones',
          imageUrl: 'https://images.example.com/ip15_fk.jpg',
          price: 129900.0,
          rating: 4.6,
          storeName: 'Flipkart',
          storeLabel: 'Flipkart.com',
          buyUrl: 'https://www.flipkart.com/p/itm1234567890',
        );

        const pCroma = Product(
          id: 'ip15_croma',
          title: 'Apple iPhone 15 Pro, 128GB, Natural Titanium',
          category: 'Smartphones',
          imageUrl: 'https://images.example.com/ip15_croma.jpg',
          price: 132990.0,
          rating: 4.5,
          storeName: 'Croma',
          storeLabel: 'Croma Retail',
          buyUrl: 'https://www.croma.com/apple-iphone-15-pro-128gb/p/272301',
        );

        final result = ProductDeduplicationService.deduplicate([
          pAmz,
          pFk,
          pCroma,
        ]);

        expect(result.length, equals(1));
        final product = result.first;

        expect(product.offers.length, equals(3));
        expect(product.price, equals(129900.0)); // Lowest price
        expect(product.savingsInr, equals(5000.0)); // 134900 - 129900 = 5000
        expect(product.matchedStore, equals('Amazon'));
        expect(product.matchedPriceInr, equals(134900.0));
      },
    );

    // 4. Different storage capacities are NOT merged
    test(
      '4. Different storage capacities (128GB vs 256GB) are strictly kept separate',
      () {
        const p128 = Product(
          id: 'ip15_128',
          title: 'Apple iPhone 15 Pro (128 GB) - Natural Titanium',
          category: 'Smartphones',
          imageUrl: 'https://images.example.com/ip15.jpg',
          price: 129900.0,
          rating: 4.7,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0CHX1W1XY',
        );

        const p256 = Product(
          id: 'ip15_256',
          title: 'Apple iPhone 15 Pro (256 GB) - Natural Titanium',
          category: 'Smartphones',
          imageUrl: 'https://images.example.com/ip15.jpg',
          price: 139900.0,
          rating: 4.7,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0CHX1W2ZZ',
        );

        final result = ProductDeduplicationService.deduplicate([p128, p256]);

        expect(result.length, equals(2));
        expect(result[0].title, contains('128'));
        expect(result[1].title, contains('256'));
      },
    );

    // 5. Different product generations are NOT merged
    test(
      '5. Different product generations (M1 vs M2) are strictly kept separate',
      () {
        const mbaM1 = Product(
          id: 'mba_m1',
          title:
              'Apple MacBook Air Laptop with M1 chip (8GB RAM, 256GB SSD) Space Grey',
          category: 'Laptops',
          imageUrl: 'https://images.example.com/mba.jpg',
          price: 69990.0,
          rating: 4.7,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B08N5XSG8Z',
        );

        const mbaM2 = Product(
          id: 'mba_m2',
          title:
              'Apple MacBook Air Laptop with M2 chip (8GB RAM, 256GB SSD) Space Grey',
          category: 'Laptops',
          imageUrl: 'https://images.example.com/mba.jpg',
          price: 89990.0,
          rating: 4.8,
          storeName: 'Flipkart',
          storeLabel: 'Flipkart.com',
          buyUrl: 'https://www.flipkart.com/p/itmmbam2',
        );

        final result = ProductDeduplicationService.deduplicate([mbaM1, mbaM2]);

        expect(result.length, equals(2));
        expect(result[0].title, contains('M1'));
        expect(result[1].title, contains('M2'));
      },
    );

    // 6. Similar titles referring to different products are NOT merged
    test(
      '6. Similar titles referring to different product models (S24 vs S24 Ultra vs S24+) are separate',
      () {
        const s24 = Product(
          id: 's24_base',
          title: 'Samsung Galaxy S24 5G (Onyx Black, 8GB, 128GB Storage)',
          category: 'Smartphones',
          imageUrl: 'https://images.example.com/s24.jpg',
          price: 74999.0,
          rating: 4.5,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0CS5X84',
        );

        const s24Plus = Product(
          id: 's24_plus',
          title: 'Samsung Galaxy S24+ 5G (Cobalt Violet, 12GB, 256GB Storage)',
          category: 'Smartphones',
          imageUrl: 'https://images.example.com/s24p.jpg',
          price: 89999.0,
          rating: 4.6,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0CS5X99',
        );

        const s24Ultra = Product(
          id: 's24_ultra',
          title:
              'Samsung Galaxy S24 Ultra 5G (Titanium Gray, 12GB, 256GB Storage)',
          category: 'Smartphones',
          imageUrl: 'https://images.example.com/s24u.jpg',
          price: 129999.0,
          rating: 4.8,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0CS5XA1',
        );

        final result = ProductDeduplicationService.deduplicate([
          s24,
          s24Plus,
          s24Ultra,
        ]);

        expect(result.length, equals(3));
      },
    );

    // 7. Duplicate products merged with cached results
    test(
      '7. Duplicate products merged with cached results update offers without duplicating',
      () {
        final cachedList = [
          const Product(
            id: 'ps5_old',
            title: 'Sony PlayStation 5 Console (Slim Edition)',
            category: 'Electronics',
            imageUrl: 'https://images.example.com/ps5.jpg',
            price: 54990.0,
            rating: 4.8,
            storeName: 'Amazon',
            storeLabel: 'Amazon.in',
            buyUrl: 'https://www.amazon.in/dp/B0CL5P3Q1V',
          ),
        ];

        final incomingFreshList = [
          const Product(
            id: 'ps5_new_fk',
            title: 'Sony PlayStation 5 Slim Console',
            category: 'Electronics',
            imageUrl: 'https://images.example.com/ps5_fk.jpg',
            price: 52990.0, // Fresh discounted price on Flipkart
            rating: 4.9,
            storeName: 'Flipkart',
            storeLabel: 'Flipkart.com',
            buyUrl: 'https://www.flipkart.com/p/itmps5slim123',
          ),
        ];

        final merged = ProductDeduplicationService.deduplicate([
          ...cachedList,
          ...incomingFreshList,
        ]);

        expect(merged.length, equals(1));
        expect(
          merged.first.price,
          equals(52990.0),
        ); // Updated with fresh best price
        expect(merged.first.offers.length, equals(2));
        expect(merged.first.savingsInr, equals(2000.0)); // 54990 - 52990 = 2000
      },
    );

    // 8. Duplicate products appearing across pages or queries
    test(
      '8. Products appearing across multiple queries or pages are deduplicated',
      () {
        final queryMobiles = [
          const Product(
            id: 'prod_m1',
            title: 'OnePlus 12 (Silky Black, 12GB RAM, 256GB Storage)',
            category: 'Smartphones',
            imageUrl: 'https://images.example.com/op12.jpg',
            price: 64999.0,
            rating: 4.6,
            storeName: 'Amazon',
            storeLabel: 'Amazon.in',
            buyUrl: 'https://www.amazon.in/dp/B0CQ234ABC',
          ),
        ];

        final queryElectronics = [
          const Product(
            id: 'prod_m2',
            title: 'OnePlus 12 5G (Silky Black, 256GB)',
            category: 'Electronics',
            imageUrl: 'https://images.example.com/op12_e.jpg',
            price: 64999.0,
            rating: 4.6,
            storeName: 'Amazon',
            storeLabel: 'Amazon.in',
            buyUrl: 'https://www.amazon.in/dp/B0CQ234ABC',
          ),
        ];

        final combined = ProductDeduplicationService.deduplicate([
          ...queryMobiles,
          ...queryElectronics,
        ]);

        expect(combined.length, equals(1));
      },
    );

    // 9. Missing product IDs and URLs handled gracefully
    test(
      '9. Missing product IDs and generic URLs are handled gracefully without crash',
      () {
        const pMissingId = Product(
          id: '',
          title: 'boAt Airdopes 141 Bluetooth Truly Wireless in Ear Earbuds',
          category: 'Headphones',
          imageUrl: 'https://images.example.com/boat.jpg',
          price: 1299.0,
          rating: 4.1,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: null,
        );

        const pWithId = Product(
          id: 'serp_boat_141',
          title: 'boAt Airdopes 141 Bluetooth Truly Wireless Earbuds',
          category: 'Headphones',
          imageUrl: 'https://images.example.com/boat2.jpg',
          price: 1199.0,
          rating: 4.2,
          storeName: 'Flipkart',
          storeLabel: 'Flipkart.com',
          buyUrl: 'https://www.flipkart.com/p/itmboat141',
        );

        final result = ProductDeduplicationService.deduplicate([
          pMissingId,
          pWithId,
        ]);

        expect(result.length, equals(1));
        expect(result.first.price, equals(1199.0));
        expect(result.first.offers.length, equals(2));
      },
    );

    // 10. Accurate unique-product count
    test(
      '10. Accurate unique-product count reflects physical products, not raw offers',
      () {
        final raw10Offers = [
          // 3 offers for PS5
          const Product(
            id: 'p1',
            title: 'Sony PlayStation 5 Console (Slim Edition)',
            category: 'Electronics',
            imageUrl: 'https://images.example.com/ps5.jpg',
            price: 54990.0,
            rating: 4.8,
            storeName: 'Amazon',
            storeLabel: 'Amazon.in',
            buyUrl: 'https://www.amazon.in/dp/B0CL5P3Q1V',
          ),
          const Product(
            id: 'p2',
            title: 'Sony PlayStation 5 Slim Console',
            category: 'Electronics',
            imageUrl: 'https://images.example.com/ps5_fk.jpg',
            price: 53990.0,
            rating: 4.7,
            storeName: 'Flipkart',
            storeLabel: 'Flipkart.com',
            buyUrl: 'https://www.flipkart.com/p/itmps5slim123',
          ),
          const Product(
            id: 'p3',
            title: 'Sony PlayStation 5 Slim',
            category: 'Electronics',
            imageUrl: 'https://images.example.com/ps5_croma.jpg',
            price: 54490.0,
            rating: 4.8,
            storeName: 'Croma',
            storeLabel: 'Croma',
            buyUrl: 'https://www.croma.com/ps5-slim/p/12345',
          ),

          // 2 offers for iPhone 15 Pro
          const Product(
            id: 'p4',
            title: 'Apple iPhone 15 Pro (128 GB) - Natural Titanium',
            category: 'Smartphones',
            imageUrl: 'https://images.example.com/ip15.jpg',
            price: 134900.0,
            rating: 4.7,
            storeName: 'Amazon',
            storeLabel: 'Amazon.in',
            buyUrl: 'https://www.amazon.in/dp/B0CHX1W1XY',
          ),
          const Product(
            id: 'p5',
            title: 'Apple iPhone 15 Pro 128 GB Natural Titanium',
            category: 'Smartphones',
            imageUrl: 'https://images.example.com/ip15_fk.jpg',
            price: 129900.0,
            rating: 4.6,
            storeName: 'Flipkart',
            storeLabel: 'Flipkart.com',
            buyUrl: 'https://www.flipkart.com/p/itm1234567890',
          ),

          // 1 offer for Nike shoes
          const Product(
            id: 'p6',
            title: 'Nike Air Max 270 Running Shoes',
            category: 'Shoes',
            imageUrl: 'https://images.example.com/nike.jpg',
            price: 12995.0,
            rating: 4.6,
            storeName: 'Amazon',
            storeLabel: 'Amazon.in',
            buyUrl: 'https://www.amazon.in/dp/B07N1234',
          ),
        ];

        expect(raw10Offers.length, equals(6)); // Raw offers: 6

        final deduplicated = ProductDeduplicationService.deduplicate(
          raw10Offers,
        );

        // Unique physical products: exactly 3 (PS5 Slim, iPhone 15 Pro 128GB, Nike Air Max 270)
        expect(deduplicated.length, equals(3));
      },
    );

    // 11. Distinct hardware editions (PlayStation 5 Disc vs Digital) are kept separate
    test(
      '11. Distinct hardware editions (PlayStation 5 Disc vs Digital Edition) are strictly kept separate',
      () {
        const ps5Disc = Product(
          id: 'ps5_disc',
          title: 'Sony PlayStation 5 Console (Disc Edition)',
          category: 'Electronics',
          imageUrl: 'https://images.example.com/ps5_disc.jpg',
          price: 54990.0,
          rating: 4.8,
          storeName: 'Amazon',
          storeLabel: 'Amazon.in',
          buyUrl: 'https://www.amazon.in/dp/B0CL5P3Q1V',
        );

        const ps5Digital = Product(
          id: 'ps5_digital',
          title: 'Sony PlayStation 5 Console (Digital Edition)',
          category: 'Electronics',
          imageUrl: 'https://images.example.com/ps5_dig.jpg',
          price: 44990.0,
          rating: 4.7,
          storeName: 'Flipkart',
          storeLabel: 'Flipkart.com',
          buyUrl: 'https://www.flipkart.com/p/itmps5digital',
        );

        final result = ProductDeduplicationService.deduplicate([
          ps5Disc,
          ps5Digital,
        ]);

        expect(result.length, equals(2));
        expect(result.any((p) => p.title.contains('Disc')), isTrue);
        expect(result.any((p) => p.title.contains('Digital')), isTrue);
      },
    );
  });
}
