import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client.dart';
import 'deallens/providers/auth_provider.dart';
import 'deallens/providers/products_provider.dart';
import 'deallens/providers/search_provider.dart';
import 'deallens/providers/wishlist_provider.dart';
import 'deallens/screens/deallens_navigation_screen.dart';
import 'deallens/screens/login_screen.dart';
import 'deallens/theme/deallens_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  await initializeClient();

  bool isFirstTime = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('has_completed_onboarding') ?? false;
    final currentUser = FirebaseAuth.instance.currentUser;
    isFirstTime = !hasCompletedOnboarding && (currentUser == null);
  } catch (e) {
    debugPrint('Preferences/Auth check note: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: DealLensApp(
        initialScreen: isFirstTime
            ? const LoginScreen()
            : const DealLensNavigationScreen(),
      ),
    ),
  );
}

class DealLensApp extends StatelessWidget {
  final Widget initialScreen;
  const DealLensApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DealLens — India Shopping Aggregator',
      debugShowCheckedModeBanner: false,
      theme: DealLensTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: initialScreen,
    );
  }
}
