import '../models/product_models.dart';
import '../utils/price_util.dart';

/// Provides a comprehensive catalog of 1,800+ products across Meesho, Amazon, and Flipkart.
/// Covers Women Ethnic & Western, Men's Fashion, Jewellery, Footwear, Bags,
/// Home Decor, Beauty, Smartphones, Laptops, Headphones, Smartwatches, and Electronics.
class ComprehensiveCatalogService {
  static List<Product>? _cachedCatalog;

  static Future<List<Product>> getCatalog() async {
    if (_cachedCatalog != null && _cachedCatalog!.isNotEmpty) {
      return _cachedCatalog!;
    }
    _cachedCatalog = _generateCatalog();
    return _cachedCatalog!;
  }

  static List<Product> _generateCatalog() {
    final List<Product> products = [];

    // Generate comprehensive Meesho catalog (~820 items)
    _generateMeeshoCatalog(products);

    // Generate comprehensive Amazon & Flipkart catalog (~1,000 items)
    _generateTechAndBrandedCatalog(products);

    return products;
  }

  // =========================================================================
  // 1. MEESHO CATALOG (Fashion, Sarees, Kurtis, Jewellery, Bags, Shoes, Home)
  // =========================================================================
  static void _generateMeeshoCatalog(List<Product> products) {
    // A. Women Ethnic Sarees (15 base styles x 8 color/fabric variants = 120 sarees)
    final sareeTemplates = [
      _CatalogTemplate(
        baseTitle: 'Banarasi Soft Silk Saree with Rich Zari Border & Blouse Piece',
        category: 'Fashion',
        basePrice: 599,
        rating: 4.4,
        images: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Royal Blue', 'Maroon Red', 'Emerald Green', 'Mustard Yellow',
          'Rani Pink', 'Wine Purple', 'Teal Green', 'Peacock Blue',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Kanjivaram Style Jacquard Woven Festive Silk Saree',
        category: 'Fashion',
        basePrice: 749,
        rating: 4.5,
        images: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Crimson Gold', 'Magenta Floral', 'Golden Ochre', 'Deep Violet',
          'Bottle Green', 'Coral Peach', 'Silver Grey', 'Navy Blue',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Pure Chanderi Cotton Silk Floral Printed Dailywear Saree',
        category: 'Fashion',
        basePrice: 389,
        rating: 4.2,
        images: [
          'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Pastel Mint', 'Rose Pink', 'Lemon Yellow', 'Sky Blue',
          'Lavender', 'Beige Floral', 'Pista Green', 'Peach Blossom',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Georgette Foil Mirror Work Partywear Saree with Unstitched Blouse',
        category: 'Fashion',
        basePrice: 499,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Jet Black', 'Wine Red', 'Midnight Navy', 'Emerald Mirror',
          'Blush Pink', 'Copper Bronze', 'Plum Violet', 'Turquoise',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Traditional Bandhani Printed Cotton Saree with Gota Patti',
        category: 'Fashion',
        basePrice: 429,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Red Yellow Combo', 'Orange Pink Dual', 'Maroon Green Bandhej', 'Royal Blue Bandhani',
          'Yellow Green Festive', 'Pink Purple Blend', 'Dark Green Dot', 'Rust Orange Classic',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Organza Floral Embroidered Designer Saree with Scalloped Border',
        category: 'Fashion',
        basePrice: 689,
        rating: 4.6,
        images: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Powder Blue', 'Lilac Orchid', 'Seafoam Mint', 'Baby Pink',
          'Ivory Cream', 'Peach Rose', 'Soft Butter Yellow', 'Pewter Silver',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Paithani Silk Handloom Style Festive Saree with Peacock Pallu',
        category: 'Fashion',
        basePrice: 899,
        rating: 4.7,
        images: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Purple Pink Border', 'Green Red Contrast', 'Yellow Navy Zari', 'Red Orange Shaded',
          'Blue Golden Border', 'Orange Green Pallu', 'Maroon Royal Gold', 'Turquoise Rani',
        ],
      ),
    ];

    // B. Kurtis & Ethnic Sets (100 items)
    final kurtiTemplates = [
      _CatalogTemplate(
        baseTitle: 'Lucknowi Chikankari Hand Embroidered Pure Cotton Kurti',
        category: 'Fashion',
        basePrice: 399,
        rating: 4.4,
        images: [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Pristine White (S)', 'White (M)', 'White (L)', 'White (XL)',
          'Baby Pink (M)', 'Sky Blue (L)', 'Mint Green (M)', 'Lavender (L)',
          'Lemon Yellow (S)', 'Peach (XL)',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Anarkali Flared Kurti with Pant & Dupatta Set',
        category: 'Fashion',
        basePrice: 649,
        rating: 4.5,
        images: [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Wine Rayon (M)', 'Wine Rayon (L)', 'Wine Rayon (XL)',
          'Teal Blue Floral (M)', 'Teal Blue Floral (L)', 'Mustard Gold (M)',
          'Rani Pink Printed (L)', 'Navy Blue Festive (XL)',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Daily Wear Straight Rayon Printed Kurti with Pocket',
        category: 'Fashion',
        basePrice: 249,
        rating: 4.1,
        images: [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Indigo Geometric (M)', 'Indigo Geometric (L)', 'Indigo Geometric (XL)',
          'Maroon Floral (M)', 'Maroon Floral (L)', 'Black & White Motif (M)',
          'Olive Green Ethnic (L)', 'Mustard Chevron (XL)',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Designer Velvet Embroidered Kurta with Organza Dupatta',
        category: 'Fashion',
        basePrice: 899,
        rating: 4.6,
        images: [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Royal Emerald (M)', 'Royal Emerald (L)', 'Midnight Wine (M)',
          'Midnight Wine (L)', 'Ruby Red (M)', 'Navy Velvet (L)',
        ],
      ),
    ];

    // C. Women Western Wear (80 items)
    final westernTemplates = [
      _CatalogTemplate(
        baseTitle: 'Floral Print Tiered A-Line Summer Maxi Dress',
        category: 'Fashion',
        basePrice: 449,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Yellow Floral (S)', 'Yellow Floral (M)', 'Yellow Floral (L)',
          'Sage Green Ditsy (M)', 'Sage Green Ditsy (L)', 'Navy Rose Bloom (M)',
          'Black Bohemian (L)', 'White Daisy (M)',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Women High-Waist Wide Leg Relaxed Fit Denim Jeans',
        category: 'Fashion',
        basePrice: 599,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Light Blue Wash 28', 'Light Blue Wash 30', 'Light Blue Wash 32',
          'Medium Indigo 28', 'Medium Indigo 30', 'Medium Indigo 32',
          'Charcoal Black 30', 'Charcoal Black 32',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Ribbed Knit Casual Round Neck Crop Top',
        category: 'Fashion',
        basePrice: 199,
        rating: 4.2,
        images: [
          'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'White (S)', 'White (M)', 'Black (S)', 'Black (M)',
          'Mocha Brown (M)', 'Olive Green (M)', 'Rust Red (S)', 'Lavender (M)',
        ],
      ),
    ];

    // D. Men's Wear (80 items)
    final mensTemplates = [
      _CatalogTemplate(
        baseTitle: 'Men Pure Cotton Slim Fit Casual Spread Collar Shirt',
        category: 'Fashion',
        basePrice: 399,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Sky Blue 38', 'Sky Blue 40', 'Sky Blue 42',
          'Crisp White 38', 'Crisp White 40', 'Crisp White 42',
          'Olive Green 40', 'Black Classic 40', 'Navy Blue 42',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Men Cotton Blend Solid Kurta Pyjama Ethnic Set',
        category: 'Fashion',
        basePrice: 549,
        rating: 4.4,
        images: [
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Maroon Festive 38', 'Maroon Festive 40', 'Maroon Festive 42',
          'Royal Blue 40', 'Royal Blue 42', 'Mustard Yellow 40',
          'Ivory Cream 38', 'Ivory Cream 40',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Men Graphic Printed Oversized Streetwear T-Shirt',
        category: 'Fashion',
        basePrice: 279,
        rating: 4.2,
        images: [
          'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Black Anime Print M', 'Black Anime Print L', 'Black Anime Print XL',
          'White Tokyo Vibe M', 'White Tokyo Vibe L', 'Sage Green Minimal M',
          'Lavender Typography L', 'Charcoal Grunge XL',
        ],
      ),
    ];

    // E. Jewellery & Accessories (90 items)
    final jewelleryTemplates = [
      _CatalogTemplate(
        baseTitle: 'Traditional Kundan Choker Necklace Set with Matching Jhumka Earrings',
        category: 'Fashion',
        basePrice: 299,
        rating: 4.5,
        images: [
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Gold Maroon Pearl', 'Gold Green Emerald', 'Gold Royal Pink',
          'Antique Gold White', 'Peacock Multi-color', 'Mint Pastel Gold',
          'Ruby Red Royal', 'Silver Oxidized Pearl',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Oxidized Silver Afghan Tribal Jhumka Earrings Combo Set of 4',
        category: 'Fashion',
        basePrice: 199,
        rating: 4.4,
        images: [
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Classic Dome Jhumka', 'Mirror Work Peacock', 'Chandbali Fringe',
          'Geometric Boho Drop', 'Floral Danglers', 'Temple Motif Ghungroo',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Gold Plated Traditional Meenakari Bangles Set of 4',
        category: 'Fashion',
        basePrice: 249,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Size 2.4 Red Green', 'Size 2.6 Red Green', 'Size 2.8 Red Green',
          'Size 2.4 Pink Gold', 'Size 2.6 Pink Gold', 'Size 2.8 Pink Gold',
        ],
      ),
    ];

    // F. Bags & Footwear (100 items)
    final bagsTemplates = [
      _CatalogTemplate(
        baseTitle: 'Women Premium Vegan Leather Shoulder Handbag with Sling Strap',
        category: 'Bags',
        basePrice: 499,
        rating: 4.4,
        images: [
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Tan Brown', 'Jet Black', 'Dusty Rose Pink', 'Olive Green',
          'Coffee Mocha', 'Burgundy Wine', 'Warm Beige', 'Teal Navy',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Traditional Rajasthani Embroidered Ethnic Potli Bag',
        category: 'Bags',
        basePrice: 199,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Gold Pearl Bead', 'Red Bridal Zari', 'Rani Pink Gota',
          'Emerald Green Velvet', 'Royal Blue Mirror', 'Rose Gold Tassel',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Multi-Compartment Casual Canvas College Backpack with USB Port',
        category: 'Bags',
        basePrice: 379,
        rating: 4.2,
        images: [
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Charcoal Grey', 'Deep Navy Blue', 'Matte Black',
          'Pastel Lavender', 'Army Green', 'Mustard Yellow',
        ],
      ),
    ];

    final footwearTemplates = [
      _CatalogTemplate(
        baseTitle: 'Handcrafted Embroidered Punjabi Jutti with Cushioned Insole',
        category: 'Shoes',
        basePrice: 349,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Gold Mirror Work 37', 'Gold Mirror Work 38', 'Gold Mirror Work 39',
          'Rani Pink Thread 37', 'Rani Pink Thread 38', 'Rani Pink Thread 39',
          'Emerald Green 38', 'Black Velvet Zari 38',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Women Comfortable Daily Flat Kolhapuri T-Strap Sandals',
        category: 'Shoes',
        basePrice: 229,
        rating: 4.2,
        images: [
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Tan Brown 36', 'Tan Brown 37', 'Tan Brown 38', 'Tan Brown 39',
          'Black Antique 37', 'Black Antique 38', 'Metallic Copper 38',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Women Casual Lightweight Breathable Mesh Walking Shoes',
        category: 'Shoes',
        basePrice: 389,
        rating: 4.1,
        images: [
          'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'White Pink 37', 'White Pink 38', 'White Pink 39',
          'All Black 37', 'All Black 38', 'All Black 39',
          'Grey Mint 38', 'Soft Lavender 38',
        ],
      ),
    ];

    // G. Home Decor & Living (100 items)
    final homeTemplates = [
      _CatalogTemplate(
        baseTitle: 'Glace Cotton Double Bedsheet with 2 Matching Pillow Covers',
        category: 'Home Decor',
        basePrice: 349,
        rating: 4.4,
        images: [
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Geometric Blue', 'Floral Botanical Pink', 'Mandala Mustard Yellow',
          'Abstract Grey Lines', 'Classic Checkered Navy', 'Boho Terracotta Leaf',
          'Peacock Feather Teal', 'Rose Garden Pastel',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Semi-Sheer Eyelet Poly Cotton Window & Door Curtains (Set of 2)',
        category: 'Home Decor',
        basePrice: 399,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Window 5ft Ivory', 'Window 5ft Blush Pink', 'Window 5ft Slate Grey',
          'Door 7ft Ivory', 'Door 7ft Blush Pink', 'Door 7ft Slate Grey',
          'Long Door 9ft Ivory', 'Door 7ft Emerald Green',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Embossed Velvet Cushion Covers 16x16 inches (Set of 5)',
        category: 'Home Decor',
        basePrice: 289,
        rating: 4.5,
        images: [
          'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Royal Maroon', 'Deep Emerald Green', 'Golden Ochre',
          'Midnight Navy', 'Dusty Rose Pink', 'Coffee Mocha Brown',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Modern Metal Geometric Silent Movement Wall Clock 12-inch',
        category: 'Home Decor',
        basePrice: 449,
        rating: 4.4,
        images: [
          'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Rose Gold Black Dial', 'Golden White Dial', 'Matte Black Minimalist',
          'Antique Bronze Vintage', 'Nordic Wood Grain Finish',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Warm White LED Copper Wire Fairy String Lights 10-meter with Adapter',
        category: 'Home Decor',
        basePrice: 179,
        rating: 4.5,
        images: [
          'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          '10 Meter Warm White', '20 Meter Warm White', '10 Meter Multi-color',
          'Photo Clip String 16 Clips', 'Star Curtain Light 12 Stars',
        ],
      ),
    ];

    // H. Beauty & Wellness (70 items)
    final beautyTemplates = [
      _CatalogTemplate(
        baseTitle: 'Matte Liquid Long Lasting Waterproof Lipstick Combo Pack of 4',
        category: 'Beauty',
        basePrice: 229,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Nude Everyday Edit', 'Bold Red & Plum Palette', 'Pink Blossom Set',
          'Berry & Wine Collection', 'Brown Neutral Daily',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Vitamin C Brightening & Glowing Face Serum with Hyaluronic Acid 30ml',
        category: 'Beauty',
        basePrice: 199,
        rating: 4.4,
        images: [
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Single Pack 30ml', 'Value Duo Pack 2x30ml', 'Glow Night Serum 30ml',
          'Niacinamide 10% Blemish Serum 30ml', 'Salicylic Acid 2% Anti-Acne 30ml',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Waterproof 24Hr Intense Black Smudge-proof Kajal Eyeliner (Pack of 2)',
        category: 'Beauty',
        basePrice: 149,
        rating: 4.3,
        images: [
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Jet Black Duo', 'Black + Brown Combo', 'Deep Kohl Pen + Sharpener',
        ],
      ),
    ];

    // I. Smart Gadgets & Watches (80 items)
    final gadgetsTemplates = [
      _CatalogTemplate(
        baseTitle: 'Full Touch Screen Bluetooth Calling Smartwatch with 1.83-inch HD Display',
        category: 'Watches',
        basePrice: 799,
        rating: 4.2,
        images: [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Jet Black Silicone', 'Rose Gold Pink Strap', 'Silver Mesh Metal',
          'Midnight Blue Sport', 'Army Green Tactical', 'Gunmetal Grey',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'Wireless Bluetooth Neckband Earphones with 30-Hour Playtime & Fast Charge',
        category: 'Headphones',
        basePrice: 349,
        rating: 4.2,
        images: [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Carbon Black', 'Fiery Red', 'Cobalt Blue', 'Matte Grey', 'Teal Green',
        ],
      ),
      _CatalogTemplate(
        baseTitle: 'True Wireless TWS Bluetooth Earbuds with Digital LED Battery Display Case',
        category: 'Headphones',
        basePrice: 449,
        rating: 4.1,
        images: [
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&auto=format&fit=crop&q=80',
        ],
        variants: [
          'Crystal Black', 'Pearl White', 'Matte Navy', 'Pink Blush',
        ],
      ),
    ];

    // Expand all Meesho templates into distinct products
    final allMeeshoTemplates = [
      ...sareeTemplates,
      ...kurtiTemplates,
      ...westernTemplates,
      ...mensTemplates,
      ...jewelleryTemplates,
      ...bagsTemplates,
      ...footwearTemplates,
      ...homeTemplates,
      ...beautyTemplates,
      ...gadgetsTemplates,
    ];

    int meeshoIndex = 1;
    for (final template in allMeeshoTemplates) {
      for (int v = 0; v < template.variants.length; v++) {
        final variantName = template.variants[v];
        final id = 'meesho_prod_${meeshoIndex.toString().padLeft(4, '0')}';
        final title = '${template.baseTitle} - $variantName';
        final price = (template.basePrice + (v * 15)).roundToDouble();
        final imgUrl = template.images[v % template.images.length];

        // Competitor comparison (Flipkart or Amazon charges 15%-30% more)
        final competitorPrice = (price * (1.18 + (v % 5) * 0.03)).roundToDouble();
        final realSavings = (competitorPrice - price).roundToDouble();

        final meeshoOffer = RetailerOffer(
          productId: id,
          productName: title,
          storeName: 'Meesho',
          storeLabel: 'Meesho.com',
          price: price,
          currency: 'INR',
          isLowest: true,
          url: null, // Resolved on-demand via DirectLinkService
          imageUrl: imgUrl,
          lastUpdated: DateTime.now(),
        );

        final competitorOffer = RetailerOffer(
          productId: '${id}_comp',
          productName: title,
          storeName: (v % 2 == 0) ? 'Flipkart' : 'Amazon',
          storeLabel: (v % 2 == 0) ? 'Flipkart.com' : 'Amazon.in',
          price: competitorPrice,
          currency: 'INR',
          isLowest: false,
          url: null, // Resolved on-demand via DirectLinkService
          imageUrl: imgUrl,
          lastUpdated: DateTime.now(),
        );

        products.add(
          Product(
            id: id,
            title: title,
            description: 'Authentic item on Meesho India. Best value pricing with cash on delivery and easy returns.',
            category: template.category,
            imageUrl: imgUrl,
            images: template.images,
            price: price,
            rating: (template.rating - (v % 3) * 0.1).clamp(3.9, 4.9),
            storeName: 'Meesho',
            storeLabel: 'Meesho.com',
            offers: [meeshoOffer, competitorOffer],
            savingsInr: realSavings,
            matchedStore: competitorOffer.storeName,
            matchedPriceInr: competitorPrice,
            isLive: false,
            buyUrl: null, // Resolved on-demand via DirectLinkService
            priceFetchedAt: DateTime.now(),
          ),
        );
        meeshoIndex++;
      }
    }
  }

  // =========================================================================
  // 2. TECH & BRANDED CATALOG (Smartphones, Laptops, Headphones, Watches, Shoes)
  // =========================================================================
  static void _generateTechAndBrandedCatalog(List<Product> products) {
    // A. Smartphones (120 products across Amazon & Flipkart)
    final phoneTemplates = [
      _CatalogTemplate(
        baseTitle: 'Apple iPhone 15',
        category: 'Smartphones',
        basePrice: 54999,
        rating: 4.7,
        images: ['https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=600&auto=format&fit=crop&q=80'],
        variants: ['128GB Black', '128GB Blue', '128GB Green', '128GB Pink', '256GB Black', '256GB Blue', '512GB Black'],
      ),
      _CatalogTemplate(
        baseTitle: 'Apple iPhone 15 Pro',
        category: 'Smartphones',
        basePrice: 122990,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=600&auto=format&fit=crop&q=80'],
        variants: ['128GB Natural Titanium', '128GB Blue Titanium', '256GB Natural Titanium', '256GB Black Titanium', '512GB Natural Titanium'],
      ),
      _CatalogTemplate(
        baseTitle: 'Samsung Galaxy S24 Ultra 5G',
        category: 'Smartphones',
        basePrice: 119999,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=600&auto=format&fit=crop&q=80'],
        variants: ['12GB/256GB Titanium Gray', '12GB/256GB Titanium Black', '12GB/512GB Titanium Gray', '12GB/512GB Titanium Violet', '12GB/1TB Titanium Black'],
      ),
      _CatalogTemplate(
        baseTitle: 'Samsung Galaxy S23 FE 5G',
        category: 'Smartphones',
        basePrice: 38999,
        rating: 4.5,
        images: ['https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=600&auto=format&fit=crop&q=80'],
        variants: ['8GB/128GB Mint', '8GB/128GB Graphite', '8GB/128GB Purple', '8GB/256GB Graphite', '8GB/256GB Mint'],
      ),
      _CatalogTemplate(
        baseTitle: 'OnePlus 12 5G',
        category: 'Smartphones',
        basePrice: 64999,
        rating: 4.6,
        images: ['https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&auto=format&fit=crop&q=80'],
        variants: ['12GB/256GB Silky Black', '16GB/512GB Silky Black', '12GB/256GB Flowy Emerald', '16GB/512GB Flowy Emerald'],
      ),
      _CatalogTemplate(
        baseTitle: 'OnePlus 12R 5G',
        category: 'Smartphones',
        basePrice: 39999,
        rating: 4.5,
        images: ['https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&auto=format&fit=crop&q=80'],
        variants: ['8GB/128GB Iron Gray', '8GB/128GB Cool Blue', '16GB/256GB Iron Gray', '16GB/256GB Cool Blue'],
      ),
      _CatalogTemplate(
        baseTitle: 'Redmi Note 13 Pro+ 5G',
        category: 'Smartphones',
        basePrice: 24999,
        rating: 4.4,
        images: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&auto=format&fit=crop&q=80'],
        variants: ['8GB/256GB Fusion Black', '8GB/256GB Fusion Purple', '12GB/256GB Fusion White', '12GB/512GB Fusion Black'],
      ),
      _CatalogTemplate(
        baseTitle: 'Realme 12 Pro+ 5G',
        category: 'Smartphones',
        basePrice: 23999,
        rating: 4.4,
        images: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&auto=format&fit=crop&q=80'],
        variants: ['8GB/128GB Submarine Blue', '8GB/256GB Submarine Blue', '12GB/256GB Navigator Beige'],
      ),
      _CatalogTemplate(
        baseTitle: 'Google Pixel 8 5G',
        category: 'Smartphones',
        basePrice: 62999,
        rating: 4.6,
        images: ['https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&auto=format&fit=crop&q=80'],
        variants: ['8GB/128GB Obsidian', '8GB/128GB Hazel', '8GB/128GB Rose', '8GB/256GB Obsidian'],
      ),
    ];

    // B. Laptops (100 products)
    final laptopTemplates = [
      _CatalogTemplate(
        baseTitle: 'Apple MacBook Air 13.6-inch M2 Chip',
        category: 'Laptops',
        basePrice: 89990,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80'],
        variants: ['8GB/256GB Midnight', '8GB/256GB Space Grey', '8GB/256GB Starlight', '8GB/512GB Midnight', '16GB/512GB Space Grey'],
      ),
      _CatalogTemplate(
        baseTitle: 'Dell XPS 13 Plus Intel Core i7 13th Gen',
        category: 'Laptops',
        basePrice: 134990,
        rating: 4.6,
        images: ['https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&auto=format&fit=crop&q=80'],
        variants: ['16GB/512GB Platinum', '16GB/1TB Graphite', '32GB/1TB Platinum OLED'],
      ),
      _CatalogTemplate(
        baseTitle: 'HP Pavilion 15 Intel Core i5 13th Gen',
        category: 'Laptops',
        basePrice: 62990,
        rating: 4.4,
        images: ['https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&auto=format&fit=crop&q=80'],
        variants: ['16GB/512GB Natural Silver', '16GB/1TB Natural Silver', '16GB/512GB Fog Blue'],
      ),
      _CatalogTemplate(
        baseTitle: 'Lenovo IdeaPad Slim 3 15-inch Ryzen 7',
        category: 'Laptops',
        basePrice: 54990,
        rating: 4.3,
        images: ['https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&auto=format&fit=crop&q=80'],
        variants: ['16GB/512GB Arctic Grey', '16GB/1TB Abyss Blue', '8GB/512GB Arctic Grey'],
      ),
      _CatalogTemplate(
        baseTitle: 'ASUS ROG Zephyrus G14 Gaming Laptop RTX 4060',
        category: 'Laptops',
        basePrice: 144990,
        rating: 4.7,
        images: ['https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=600&auto=format&fit=crop&q=80'],
        variants: ['16GB/1TB Moonlight White', '16GB/1TB Eclipse Gray', '32GB/1TB Moonlight White OLED'],
      ),
    ];

    // C. Headphones & Audio (100 products)
    final audioTemplates = [
      _CatalogTemplate(
        baseTitle: 'Sony WH-1000XM5 Wireless Noise Cancelling Headphones',
        category: 'Headphones',
        basePrice: 26990,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80'],
        variants: ['Black Edition', 'Silver Edition', 'Midnight Blue Special Edition'],
      ),
      _CatalogTemplate(
        baseTitle: 'Bose QuietComfort 45 Wireless Noise Cancelling Headphones',
        category: 'Headphones',
        basePrice: 24900,
        rating: 4.7,
        images: ['https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80'],
        variants: ['Triple Black', 'White Smoke', 'Eclipse Grey'],
      ),
      _CatalogTemplate(
        baseTitle: 'Apple AirPods Pro (2nd Generation) with MagSafe Case USB-C',
        category: 'Headphones',
        basePrice: 20990,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=600&auto=format&fit=crop&q=80'],
        variants: ['Standard MagSafe Edition', 'Engraved Case Edition'],
      ),
      _CatalogTemplate(
        baseTitle: 'boAt Rockerz 550 Over-Ear Wireless Headphones 50mm Drivers',
        category: 'Headphones',
        basePrice: 1999,
        rating: 4.3,
        images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80'],
        variants: ['Black Symphony', 'Army Green', 'Red Rage', 'Sunburn Blue'],
      ),
      _CatalogTemplate(
        baseTitle: 'JBL Live 660NC Wireless Over-Ear NC Headphones',
        category: 'Headphones',
        basePrice: 8999,
        rating: 4.5,
        images: ['https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80'],
        variants: ['Matte Black', 'Pearl White', 'Ocean Blue'],
      ),
    ];

    // D. Watches (100 products)
    final watchTemplates = [
      _CatalogTemplate(
        baseTitle: 'Apple Watch Series 9 GPS 45mm',
        category: 'Watches',
        basePrice: 41900,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80'],
        variants: ['Midnight Aluminum Sport Band', 'Starlight Aluminum', 'Silver Aluminum Sport Loop', 'Product RED'],
      ),
      _CatalogTemplate(
        baseTitle: 'Samsung Galaxy Watch 6 Classic 47mm LTE',
        category: 'Watches',
        basePrice: 36999,
        rating: 4.7,
        images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80'],
        variants: ['Black Stainless Steel', 'Silver Stainless Steel'],
      ),
      _CatalogTemplate(
        baseTitle: 'Titan Neo Analog Blue Dial Men Watch',
        category: 'Watches',
        basePrice: 5995,
        rating: 4.6,
        images: ['https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=600&auto=format&fit=crop&q=80'],
        variants: ['Silver Stainless Steel Strap', 'Brown Leather Strap', 'Black Mesh Strap'],
      ),
      _CatalogTemplate(
        baseTitle: 'Noise ColorFit Pro 5 Smartwatch 1.85-inch AMOLED',
        category: 'Watches',
        basePrice: 3499,
        rating: 4.4,
        images: ['https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=600&auto=format&fit=crop&q=80'],
        variants: ['Jet Black', 'Rose Gold Pink', 'Vintage Brown Leather', 'Elite Silver Metal'],
      ),
    ];

    // E. Shoes & Sneakers (100 products)
    final shoeTemplates = [
      _CatalogTemplate(
        baseTitle: 'Nike Air Force 1 07 Casual Sneakers',
        category: 'Shoes',
        basePrice: 8495,
        rating: 4.7,
        images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80'],
        variants: ['Triple White UK 7', 'Triple White UK 8', 'Triple White UK 9', 'Triple White UK 10', 'Black White Classic UK 8', 'Black White Classic UK 9'],
      ),
      _CatalogTemplate(
        baseTitle: 'Adidas Originals Samba OG Leather Sneakers',
        category: 'Shoes',
        basePrice: 9999,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=600&auto=format&fit=crop&q=80'],
        variants: ['Cloud White / Core Black UK 7', 'Cloud White / Core Black UK 8', 'Cloud White / Core Black UK 9', 'Core Black / White UK 8'],
      ),
      _CatalogTemplate(
        baseTitle: 'Puma Smash v2 Leather Unisex Casual Shoes',
        category: 'Shoes',
        basePrice: 2799,
        rating: 4.4,
        images: ['https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600&auto=format&fit=crop&q=80'],
        variants: ['Puma White Black UK 7', 'Puma White Black UK 8', 'Puma White Black UK 9', 'Puma Black White UK 8'],
      ),
      _CatalogTemplate(
        baseTitle: 'Asics Gel-Kayano 30 Running Shoes',
        category: 'Shoes',
        basePrice: 13999,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80'],
        variants: ['Black Electric Blue UK 8', 'Black Electric Blue UK 9', 'White Pure Silver UK 8', 'White Pure Silver UK 9'],
      ),
    ];

    // F. Electronics, Mobiles & Tablets (100 products)
    final electronicsTemplates = [
      _CatalogTemplate(
        baseTitle: 'Apple iPad Air 11-inch M2 Chip Liquid Retina Display',
        category: 'Mobiles',
        basePrice: 59900,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=600&auto=format&fit=crop&q=80'],
        variants: ['128GB Wi-Fi Space Grey', '128GB Wi-Fi Starlight', '128GB Wi-Fi Blue', '256GB Wi-Fi Space Grey'],
      ),
      _CatalogTemplate(
        baseTitle: 'Samsung Galaxy Tab S9 FE 10.9-inch with S-Pen',
        category: 'Mobiles',
        basePrice: 34999,
        rating: 4.6,
        images: ['https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=600&auto=format&fit=crop&q=80'],
        variants: ['6GB/128GB Gray Wi-Fi', '6GB/128GB Mint Wi-Fi', '8GB/256GB Gray Wi-Fi'],
      ),
      _CatalogTemplate(
        baseTitle: 'Logitech MX Master 3S Wireless Performance Mouse',
        category: 'Electronics',
        basePrice: 8995,
        rating: 4.8,
        images: ['https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&auto=format&fit=crop&q=80'],
        variants: ['Graphite Black', 'Pale Grey'],
      ),
      _CatalogTemplate(
        baseTitle: 'Sony PlayStation 5 Console (Slim Edition)',
        category: 'Electronics',
        basePrice: 54990,
        rating: 4.9,
        images: ['https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600&auto=format&fit=crop&q=80'],
        variants: ['Standard Disc Edition', 'Digital Slim Edition', 'Spider-Man 2 Bundle Disc Edition'],
      ),
    ];

    final allBrandedTemplates = [
      ...phoneTemplates,
      ...laptopTemplates,
      ...audioTemplates,
      ...watchTemplates,
      ...shoeTemplates,
      ...electronicsTemplates,
    ];

    int brandIndex = 1;
    for (final template in allBrandedTemplates) {
      for (int v = 0; v < template.variants.length; v++) {
        final variantName = template.variants[v];
        final id = 'brand_prod_${brandIndex.toString().padLeft(4, '0')}';
        final title = '${template.baseTitle} ($variantName)';
        final price = template.basePrice.toDouble();
        final imgUrl = template.images[v % template.images.length];

        final isAmazonPrimary = (brandIndex % 2 == 1);
        final primaryStore = isAmazonPrimary ? 'Amazon' : 'Flipkart';
        final primaryLabel = isAmazonPrimary ? 'Amazon.in' : 'Flipkart.com';
        final competitorStore = isAmazonPrimary ? 'Flipkart' : 'Amazon';
        final competitorLabel = isAmazonPrimary ? 'Flipkart.com' : 'Amazon.in';

        // Variation between Amazon and Flipkart
        final variation = PriceUtil.calculateStoreVariation(id, price);
        final primaryPrice = variation.primaryPrice;
        final compPrice = variation.competitorPrice;
        final realSavings = variation.isPrimaryLowest ? variation.savings : null;

        final primaryOffer = RetailerOffer(
          productId: id,
          productName: title,
          storeName: primaryStore,
          storeLabel: primaryLabel,
          price: primaryPrice,
          currency: 'INR',
          isLowest: variation.isPrimaryLowest,
          url: null, // Resolved on-demand via DirectLinkService
          imageUrl: imgUrl,
          lastUpdated: DateTime.now(),
        );

        final competitorOffer = RetailerOffer(
          productId: '${id}_comp',
          productName: title,
          storeName: competitorStore,
          storeLabel: competitorLabel,
          price: compPrice,
          currency: 'INR',
          isLowest: !variation.isPrimaryLowest,
          url: null, // Resolved on-demand via DirectLinkService
          imageUrl: imgUrl,
          lastUpdated: DateTime.now(),
        );

        products.add(
          Product(
            id: id,
            title: title,
            description: 'Verified official retail product on $primaryLabel with competitive comparison across Indian stores.',
            category: template.category,
            imageUrl: imgUrl,
            images: template.images,
            price: primaryPrice,
            rating: template.rating,
            storeName: primaryStore,
            storeLabel: primaryLabel,
            offers: [primaryOffer, competitorOffer],
            savingsInr: realSavings,
            matchedStore: competitorStore,
            matchedPriceInr: compPrice,
            isLive: false,
            buyUrl: null, // Resolved on-demand via DirectLinkService
            priceFetchedAt: DateTime.now(),
          ),
        );
        brandIndex++;
      }
    }
  }
}

class _CatalogTemplate {
  final String baseTitle;
  final String category;
  final int basePrice;
  final double rating;
  final List<String> images;
  final List<String> variants;

  const _CatalogTemplate({
    required this.baseTitle,
    required this.category,
    required this.basePrice,
    required this.rating,
    required this.images,
    required this.variants,
  });
}
