import 'package:flutter/material.dart';
import '../theme/deallens_theme.dart';

/// Section header with title and optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onSeeAll;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'See All',
    this.onSeeAll,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final callback = onActionTap ?? onSeeAll;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: DealLensTheme.textNavy,
            ),
          ),
          if (callback != null)
            TextButton(
              onPressed: callback,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: DealLensTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
