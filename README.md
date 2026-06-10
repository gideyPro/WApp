# WaveMart

Your trusted property marketplace mobile application.

## Overview

WaveMart is a Flutter-powered property listing platform enabling users to buy, sell, and rent properties in Ethiopia. It connects property seekers with sellers and landlords through a comprehensive feature set including listings, messaging, video calls, and secure payments.

## Features

- **Property Listings** — Browse, search, and filter properties (houses, land)
- **Listing Creation** — Multi-step wizard with draft auto-save
- **OTP Authentication** — Phone-based login and verification
- **In-app Messaging** — Direct conversations with sellers
- **Video Calls** — Jitsi-powered property tours
- **KYC Verification** — Identity verification for trusted transactions
- **Subscription Plans** — Tiered access with Chapa payments
- **Push Notifications** — Real-time updates
- **Favorites** — Save and revisit properties
- **Multi-language** — English, Amharic, and Tigrinya

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| HTTP Client | Dio |
| Local Storage | Hive + flutter_secure_storage |
| Theming | Material Design 3 |
| Video | Jitsi Meet |
| Payments | Chapa |

## Project Structure

```
lib/
├── core/
│   ├── constants/    # App colors
│   ├── network/      # ApiClient, ApiConstants, ErrorHandler
│   └── theme/       # AppTheme, TextStyles
├── data/
│   ├── models/      # User, Listing, Address, Payment, Message, etc.
│   └── services/    # Auth, Listing, Favorite, Message, Payment, etc.
├── l10n/            # Localization ARB files
└── presentation/
    ├── providers/   # Riverpod providers
    ├── screens/     # All app screens
    └── widgets/     # Reusable widgets
```

## Screens

| Screen | Description |
|--------|-------------|
| Splash | App initialization |
| OTP Login | Phone + OTP verification |
| Registration | New user sign-up |
| Home | Featured and recent listings |
| Search | Property search with filters |
| Listing Detail | Full property view |
| Create Listing | Multi-step listing wizard |
| My Listings | User's own listings |
| Favorites | Saved properties |
| Profile | User profile and stats |
| Messages | Conversation list |
| Settings | App preferences |
| KYC Verification | Identity verification |
| Subscription Plans | Plan selection and billing |
| Payment History | Transaction records |
| Help Center | FAQs and support |
| Video Call | Jitsi-powered calls |

## API

The app communicates with a backend at `https://wavemart.et/api` covering:

- Authentication (send-otp, verify-otp, login, register, logout)
- Listings CRUD (create, read, update, delete, feature)
- Messaging and conversations
- Video conferences (create, join, invite)
- Payments via Chapa
- KYC submission
- Subscriptions
- Notifications
- Ethiopian address hierarchy (Region → Zone → Woreda → Kebele)

## Local Development

### Prerequisites

- Flutter SDK 3.0+
- Android SDK
- Java 17

### Setup

```bash
# Install dependencies
flutter pub get

# Generate localization
flutter gen-l10n

# Run on device/emulator
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

### Environment Variables

Override the API base URL at build time:

```bash
flutter run --dart-define=API_BASE_URL=https://staging.wavemart.et
```

## Supported Languages

| Code | Language |
|------|---------|
| `en` | English |
| `am` | Amharic |
| `ti` | Tigrinya |

## License

MIT