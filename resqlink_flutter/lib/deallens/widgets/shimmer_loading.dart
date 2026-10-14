import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/deallens_theme.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class HorizontalProductListSkeleton extends StatelessWidget {
  const HorizontalProductListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: DealLensTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DealLensTheme.borderSubtle, width: 0.8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerSkeleton(
            width: double.infinity,
            height: 120,
            borderRadius: 14,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerSkeleton(width: 120, height: 14),
                SizedBox(height: 6),
                ShimmerSkeleton(width: 80, height: 16),
                SizedBox(height: 6),
                ShimmerSkeleton(width: 60, height: 12),
                SizedBox(height: 10),
                ShimmerSkeleton(width: double.infinity, height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
