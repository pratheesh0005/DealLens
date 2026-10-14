import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/deallens_theme.dart';
import 'shimmer_loading.dart';

/// Amazon-style multiple product image gallery with:
/// - Horizontal swipe between multiple images
/// - Real unique images only (no fake dots if single image)
/// - Pinch-to-zoom & double-tap zoom
/// - Page indicator dots
/// - Current image counter badge (e.g. 1/4)
/// - Efficient caching and shimmer loading placeholders
class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final double height;

  const ProductImageGallery({
    super.key,
    required this.images,
    this.height = 280,
  });

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validImages = widget.images
        .where((img) => img.trim().isNotEmpty && img.startsWith('http'))
        .toList();

    // 1. Zero images available: display fallback placeholder
    if (validImages.isEmpty) {
      return Container(
        width: double.infinity,
        height: widget.height,
        color: DealLensTheme.surfaceGrey,
        child: const Center(
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: DealLensTheme.textMuted,
          ),
        ),
      );
    }

    // 2. Exactly one image: single image viewer with zoom, NO fake dots or counter
    if (validImages.length == 1) {
      return Container(
        width: double.infinity,
        height: widget.height,
        color: DealLensTheme.surfaceGrey,
        child: _ZoomableImageItem(imageUrl: validImages.first),
      );
    }

    // 3. Multiple images: horizontal PageView, counter badge, and dots
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: widget.height,
          color: DealLensTheme.surfaceGrey,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: validImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _ZoomableImageItem(imageUrl: validImages[index]);
                },
              ),

              // Current image counter badge (e.g. "1/4") on bottom right
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${validImages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Page indicator dots below image
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(validImages.length, (index) {
            final isSelected = _currentIndex == index;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? DealLensTheme.primaryBlue
                      : DealLensTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Zoomable image with pinch-to-zoom and double-tap zoom
class _ZoomableImageItem extends StatefulWidget {
  final String imageUrl;

  const _ZoomableImageItem({required this.imageUrl});

  @override
  State<_ZoomableImageItem> createState() => _ZoomableImageItemState();
}

class _ZoomableImageItemState extends State<_ZoomableImageItem> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else if (_doubleTapDetails != null) {
      final position = _doubleTapDetails!.localPosition;
      _controller.value = Matrix4.identity()
        ..translateByDouble(-position.dx, -position.dy, 0.0, 1.0)
        ..scaleByDouble(2.0, 2.0, 1.0, 1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1.0,
        maxScale: 3.5,
        clipBehavior: Clip.none,
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: ShimmerSkeleton(
              width: double.infinity,
              height: 280,
              borderRadius: 0,
            ),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: DealLensTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
