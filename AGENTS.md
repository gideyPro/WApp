# AGENTS.md

## Repository layout
- Root: Flutter 3.38 mobile app
- `WaveMart/`: Laravel 12 backend (Sanctum + OTP auth)
- `design-system/`: placeholder dir (empty)

## Flutter app
- **State**: Riverpod | **Navigation**: go_router | **HTTP**: Dio
- **Local**: Hive (boxes: `listing_drafts`, `app_preferences`) + `flutter_secure_storage` (auth tokens)
- **Firebase**: `firebase_options.dart` committed; regenerate via `flutterfire configure`
- **Google Fonts**: bundled locally (`assets/fonts/`); `allowRuntimeFetching = false`
- **Orientation**: portrait-locked
- **L10n**: `generate: true` in pubspec → `flutter gen-l10n` runs auto on build/run; source ARBs in `lib/l10n/app_{en,am,ti}.arb`; Tigrinya falls back to Amharic Material/Widgets/Cupertino localizations (see `main.dart`)
- **No Flutter tests** exist; verify manually
- Key features: Jitsi video calls, Chapa payments, KYC, subscriptions, messaging

### Commands
| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install deps |
| `flutter analyze` | Lint (flutter_lints) |
| `flutter run --dart-define=API_BASE_URL=<url>` | Run with custom API |
| `flutter build apk --debug` | Debug APK |
| `flutter build apk --release --target-platform android-arm64,android-arm` | Release APK (arm64-v8a + armeabi-v7a only; `x86_64` excluded via `--target-platform`) |
| `flutter build apk --release --split-per-abi --target-platform android-arm64,android-arm` | Split APKs (separate per ABI) |
| `dart run build_runner build --delete-conflicting-outputs` | Codegen (Hive adapters) |
| `flutter gen-l10n` | Regenerate localization Dart files |

### API constants
`lib/core/network/api_constants.dart` — `API_BASE_URL` from `--dart-define=API_BASE_URL`; defaults to `https://wavemart.et`

## Backend (Laravel 12)
- **PHP 8.2+**, **MySQL** in production; SQLite `:memory:` in tests
- **Auth**: Sanctum tokens (passwordless OTP via phone)
- `.env` required (DB, Chapa, Pusher, Firebase)
- All API routes in `routes/api.php` (prefix `/api`)
- **Pint**: `./vendor/bin/pint` for PSR-12 style fixing
- **Tests**: `composer run test` or `vendor/bin/phpunit` (config clear + phpunit, uses SQLite `:memory:`)
- Jitsi conference API flow documented with cURL examples in `API_CALL.md`
- FCM push notification setup documented in `fcm_guide.md`
- Backend has its own web UI routes (`routes/web.php`) distinct from the mobile API

### Commands
| Command | Purpose |
|---------|---------|
| `composer install` | Install PHP deps |
| `composer run setup` | Full setup: install, `.env` copy, key:generate, migrate, npm build |
| `composer run dev` | Dev server + queue + logs + Vite concurrently |
| `composer run test` | Config clear + phpunit |
| `./vendor/bin/pint` | Laravel Pint (PSR-12 style fixer) |

## CI
- Manual trigger only (`workflow_dispatch` in `.github/workflows/`)
- Two workflows: `build-debug.yml` and `build-release.yml`
- Builds APKs; uploads as artifacts (30-day retention)

## Reference docs
- `API_CALL.md` — cURL examples for auth flow, conference flow, endpoints
- `fcm_guide.md` — FCM push notification setup for Flutter + Laravel backend

### APK size
- Release APK excludes `x86_64` ABI (emulator-only) via `--target-platform android-arm64,android-arm` (or `--split-per-abi` for separate APKs)
- The `abiFilters` in `android/app/build.gradle` + `disable-abi-filtering=true` in `gradle.properties` provide a secondary filter but alone are insufficient — Flutter's engine `.so` files for all ABIs are bundled regardless. Use the `--target-platform` flag to ensure Flutter only builds engine binaries for the desired architectures.
- Universal APK: ~45 MB (vs ~60 MB with all 3 ABIs)

## Do not modify
- `.kilo/`, `.gemini/`, `.qwen/`, `.agent/` — agent state dirs
- `.opencode/` — OpenCode internal config and skills
