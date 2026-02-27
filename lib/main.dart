import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/vendor_screen.dart';
import 'models/vendor.dart';
import 'utils/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const TwendeMarketApp(),
    ),
  );
}

class TwendeMarketApp extends StatelessWidget {
  const TwendeMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TwendeMarket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/vendor') {
          final vendor = settings.arguments as Vendor;
          return MaterialPageRoute(builder: (_) => VendorScreen(vendor: vendor));
        }
        return null;
      },
    );
  }
}
