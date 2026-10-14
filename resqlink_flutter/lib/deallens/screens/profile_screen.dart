import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/deallens_theme.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';

/// Profile screen — user profile with Firebase authentication, Firestore sync status, and settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out of your DealLens account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: 'Log Out',
              onPressed: () => _confirmSignOut(context),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ── Profile / Sign In Banner Header ──────────────
            if (auth.isAuthenticated)
              _buildAuthenticatedHeader(context, auth, user!)
            else
              _buildGuestSignInBanner(context),

            const SizedBox(height: 16),

            // ── Wishlist Quick Card ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DealLensTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: DealLensTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved Products',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: DealLensTheme.textNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${wishlistProvider.count} items in your wishlist',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: wishlistProvider.isSyncedWithFirestore
                            ? DealLensTheme.savingsGreenLight
                            : DealLensTheme.surfaceGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            wishlistProvider.isSyncedWithFirestore
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_off_rounded,
                            size: 14,
                            color: wishlistProvider.isSyncedWithFirestore
                                ? DealLensTheme.savingsGreen
                                : DealLensTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            wishlistProvider.isSyncedWithFirestore
                                ? 'Firestore'
                                : 'Local',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: wishlistProvider.isSyncedWithFirestore
                                  ? DealLensTheme.savingsGreen
                                  : DealLensTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),

            // ── Preferences Section ──────────────────────────
            const _SectionTitle(title: 'Preferences'),
            _SettingsTile(
              icon: Icons.currency_rupee_rounded,
              title: 'Default Currency',
              subtitle: 'INR (₹) — Indian Rupee',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.storefront_rounded,
              title: 'Aggregated Stores',
              subtitle: 'Amazon.in, Flipkart.com & Meesho',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.cloud_sync_rounded,
              title: 'Cloud Database',
              subtitle: 'Firebase Cloud Firestore',
              trailing: Switch(
                value: wishlistProvider.isSyncedWithFirestore,
                onChanged: (val) {
                  if (!auth.isAuthenticated) {
                    _openLogin(context);
                  }
                },
              ),
              onTap: () {
                if (!auth.isAuthenticated) {
                  _openLogin(context);
                }
              },
            ),

            const Divider(height: 24),

            // ── About Section ────────────────────────────────
            const _SectionTitle(title: 'About DealLens'),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About App',
              subtitle: 'Price Comparison & Shopping Discovery',
              onTap: () => _showAbout(context),
            ),
            _SettingsTile(
              icon: Icons.api_rounded,
              title: 'Data Sources & Live Search',
              subtitle: 'SerpApi Google Shopping + 3 Store APIs',
              onTap: () {},
            ),

            // ── Logout Action ────────────────────────────────
            if (auth.isAuthenticated) ...[
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedHeader(
    BuildContext context,
    AuthProvider auth,
    dynamic user,
  ) {
    final theme = Theme.of(context);
    final initial = auth.displayName.isNotEmpty
        ? auth.displayName[0].toUpperCase()
        : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: DealLensTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: DealLensTheme.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            auth.displayName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: DealLensTheme.savingsGreenLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Verified',
                            style: TextStyle(
                              color: DealLensTheme.savingsGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      auth.email,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Firestore Cloud Sync Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: DealLensTheme.savingsGreenLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: DealLensTheme.savingsGreen.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.cloud_done_rounded,
                  color: DealLensTheme.savingsGreen,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Wishlist synced with Cloud Firestore database',
                    style: TextStyle(
                      color: DealLensTheme.savingsGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestSignInBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: DealLensTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DealLensTheme.primaryBlue.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DealLensTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_circle_outlined,
                    color: DealLensTheme.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to DealLens',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: DealLensTheme.textNavy,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sign in to sync your wishlist to Firestore',
                        style: TextStyle(
                          fontSize: 12,
                          color: DealLensTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => _openLogin(context),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text(
                  'Sign In / Register with Firebase',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DealLensTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            AppLogo(size: 24, borderRadius: 6, showShadow: false),
            SizedBox(width: 8),
            Text('About DealLens'),
          ],
        ),
        content: const Text(
          'DealLens is an India-focused shopping discovery and price '
          'comparison platform built with Flutter and Firebase.\n\n'
          'Key Features:\n'
          '• Firebase Authentication (Email/Password & Guest)\n'
          '• Cloud Firestore Real-time Wishlist Database\n'
          '• Multi-Store Data Aggregation (Amazon, Flipkart, Meesho)\n'
          '• Live Google Shopping India Search via SerpApi\n'
          '• Realistic Zero-Decimal INR Retail Pricing\n'
          '• Direct Retailer "Buy Now" Redirection\n\n',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: DealLensTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: DealLensTheme.primaryBlue, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
