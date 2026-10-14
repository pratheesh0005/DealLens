import 'package:flutter/material.dart';
import '../theme/deallens_theme.dart';

/// Shimmer-style loading indicator for product lists.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final int itemCount;

  const LoadingIndicator({
    super.key,
    this.message,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message != null) ...[
          const SizedBox(height: 24),
          Text(
            message!,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
        ],
        ...List.generate(itemCount, (index) => _buildPlaceholderCard()),
      ],
    );
  }

  Widget _buildPlaceholderCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: DealLensTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: DealLensTheme.borderSubtle,
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: DealLensTheme.borderSubtle.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: 40),
                    decoration: BoxDecoration(
                      color: DealLensTheme.borderSubtle.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: DealLensTheme.borderSubtle.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

/// Simple centered circular progress indicator.
class CenteredLoader extends StatelessWidget {
  final String? message;

  const CenteredLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: DealLensTheme.primaryBlue,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
