import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../theme/deallens_theme.dart';

/// Reusable category chip/icon widget for the home screen.
class CategoryItem extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback? onTap;

  const CategoryItem({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: DealLensTheme.surfaceGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: DealLensTheme.borderSubtle,
                  width: 0.6,
                ),
              ),
              child: Icon(
                category.icon,
                color: DealLensTheme.primaryBlue,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name == 'Smartphones' ? 'Phones' : category.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: DealLensTheme.textNavy,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
