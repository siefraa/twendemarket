import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1DB954);       // Fresh green - market feel
  static const primaryDark = Color(0xFF158A3C);
  static const primaryLight = Color(0xFFE8F8EE);
  static const secondary = Color(0xFFFF6B35);     // Orange accent
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);
  static const adminPrimary = Color(0xFF2D3748);
  static const adminAccent = Color(0xFF667EEA);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}

class AppConstants {
  static const appName = 'TwendeMarket';
  static const appTagline = 'Order anything, delivered fast 🚀';

  // Firestore collections
  static const usersCollection = 'users';
  static const productsCollection = 'products';
  static const ordersCollection = 'orders';
  static const categoriesCollection = 'categories';
  static const deliveryCollection = 'deliveries';

  // Order statuses
  static const orderPending = 'pending';
  static const orderConfirmed = 'confirmed';
  static const orderPreparing = 'preparing';
  static const orderOutForDelivery = 'out_for_delivery';
  static const orderDelivered = 'delivered';
  static const orderCancelled = 'cancelled';

  // User roles
  static const roleUser = 'user';
  static const roleAdmin = 'admin';
  static const roleDelivery = 'delivery';
}
