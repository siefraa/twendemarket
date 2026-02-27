# TwendeMarket 🛒

A Flutter local market & vendors app for Tanzania.

## Features
- 🛍️ Product listings with categories
- 🏪 Vendor/seller profiles
- 🛒 Shopping cart
- 👤 User login/signup
- 🔍 Product search
- ⭐ Ratings & reviews

## Setup & Build APK

### Requirements
- Flutter SDK 3.0+
- Android Studio or VS Code
- Android SDK

### Steps

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on emulator/device
flutter run

# 3. Build release APK
flutter build apk --release

# APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

## Project Structure
```
lib/
├── main.dart              # App entry point
├── models/
│   ├── product.dart
│   ├── vendor.dart
│   └── user.dart
├── providers/
│   └── app_provider.dart  # State management
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── product_detail_screen.dart
│   └── vendor_screen.dart
├── widgets/
│   ├── product_card.dart
│   └── vendor_card.dart
└── utils/
    └── theme.dart
```

## Sample Data
The app includes 12 products from 6 vendors (Dar es Salaam, Tanzania), with categories:
- Vegetables & Fruits
- Meat & Fish
- Spices (Zanzibar)
- Fashion
- Electronics
- Natural Products

## Customization
- Edit `lib/providers/app_provider.dart` to add real products/vendors
- Replace sample data with API calls to a backend
- Update colors in `lib/utils/theme.dart`
# twendemarket
