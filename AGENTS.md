# AGENTS.md

## Prerequisites
- Flutter 3.38.0 stable (pinned in CI), SDK >=3.0.0 <4.0.0
- Java 17 required for Android builds
- PHP 8.2+ for backend (Laravel 12)

## Localization
- Generated files in `lib/l10n/` are committed; run `flutter gen-l10n` only when editing ARB files

## Configuration
- Default API URL: `https://wavemart.et/api`, override with `--dart-define=API_BASE_URL=<url>`
- Google Fonts bundled locally; runtime fetching disabled

## Architecture

### Mobile App (Flutter)
- State: Riverpod | Navigation: go_router | Local storage: Hive (boxes: `listing_drafts`, `app_preferences`)
- `lib/core/`: Network, theme | `lib/data/`: Models, services | `lib/presentation/`: Providers, screens | `lib/l10n/`: en/am/ti localization

### Backend API (Laravel)
- Framework: Laravel 12.0 | Auth: Sanctum + OTP | Database: MySQL
- Location: `/opt/lampp/htdocs/WaveMart/`
- API Base: `/api` routes (see `routes/api.php`)

## Commands

### Mobile App
- `flutter pub get` - Install dependencies
- `flutter analyze` - Lint (uses flutter_lints)
- `flutter build apk --debug` - Debug APK
- `flutter build apk --release` - Release APK

### Backend API
- `composer install` - Install PHP deps
- `php artisan migrate` - Run migrations
- `php artisan serve` - Start dev server

## API Endpoints (Mobile -> Backend)

### Auth (OTP-based, no password)
- `POST /api/auth/send-otp` - Request OTP
- `POST /api/auth/login` - Login with OTP
- `POST /api/auth/register` - Register

### Public
- `GET /api/listings` - Browse listings
- `GET /api/listings/featured` - Featured
- `GET /api/addresses/regions` - Regions (cascading dropdowns)

### Authenticated (Sanctum token required)
- `GET /api/user` - Current user
- `POST /api/listings` - Create listing
- `GET|POST /api/favorites` - Favorites
- `GET|POST /api/messages` - Messaging
- `POST /api/subscriptions/*` - Subscriptions
- `POST /api/payments/*` - Payments via Chapa

## CI
- Manual trigger only (GitHub Actions workflow_dispatch)
- Builds/upload APKs

## Notes
- `.kilo/` is Kilo internal; do not modify
- No test suite exists in Flutter app; verify manually
- Backend requires `.env` configuration (DB, Chapa, Pusher keys)
- Full API cURL examples: see `API_CALL.md` (contains test tokens, conference flow)