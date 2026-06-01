# AGENTS.md

## Repository layout
- Root: Flutter 3.38 mobile app
- `WaveMart/`: Laravel 12 backend (has its own `AGENTS.md` — full backend guidance there)
- `design-system/`: placeholder dir (empty)

## Flutter app
- **State**: Riverpod | **Navigation**: go_router | **HTTP**: Dio
- **Local**: Hive (boxes: `listing_drafts`, `app_preferences`) + `flutter_secure_storage` (auth tokens)
- **Firebase**: `firebase_options.dart` in `lib/`; regenerate via `flutterfire configure`
- **Google Fonts**: bundled locally (`assets/fonts/montserrat/`, `assets/fonts/cinzel/`); `allowRuntimeFetching = false`
- **Orientation**: portrait-locked
- **L10n**: `generate: true` in pubspec → `flutter gen-l10n` runs auto on build/run; source ARBs in `lib/l10n/app_{en,am,ti}.arb`; Tigrinya falls back to Amharic Material/Widgets/Cupertino localizations (see `main.dart:355-401`)
- **No Flutter tests** exist; verify manually
- Key features: Jitsi video calls, Chapa payments, KYC, subscriptions, messaging

### Commands
| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install deps |
| `flutter analyze` | Lint (flutter_lints) |
| `flutter run --dart-define=API_BASE_URL=<url>` | Run with custom API |
| `flutter build apk --debug` | Debug APK |
| `flutter build apk --release --target-platform android-arm64,android-arm` | Release APK (arm64-v8a + armeabi-v7a only; use `--target-platform` to exclude x86_64 — `abiFilters` alone is insufficient) |
| `flutter build apk --release --split-per-abi --target-platform android-arm64,android-arm` | Split APKs per ABI |
| `dart run build_runner build --delete-conflicting-outputs` | Hive adapter codegen (no `.g.dart` files committed — run this when adding/changing Hive models) |
| `flutter gen-l10n` | Regenerate localization Dart files (auto-runs, but can invoke manually) |

### API constants
`lib/core/network/api_constants.dart` — `API_BASE_URL` from `--dart-define=API_BASE_URL`; defaults to `https://wavemart.et`

## Backend (Laravel 12)
See `WaveMart/AGENTS.md` — covers all backend commands, architecture, middleware, routes, testing, deployment, translations, and key packages. The backend has its own web UI (Blade + Alpine.js) and API routes (Sanctum-protected, used by this Flutter app).

## Reference docs
- `API_CALL.md` — cURL examples for auth flow, conference flow, endpoints
- `fcm_guide.md` — FCM push notification setup for Flutter + Laravel backend

## CI
- Manual trigger only (`workflow_dispatch` in `.github/workflows/`)
- Two workflows: `build-debug.yml` and `build-release.yml`
- Builds APKs; uploads as artifacts (30-day retention)

## Release APK size
- Universal APK excludes x86_64 via `--target-platform android-arm64,android-arm` (~45 MB vs ~60 MB with all 3 ABIs)
- The `--target-platform` flag is the effective filter; `abiFilters` in `android/app/build.gradle` + `disable-abi-filtering=true` in `gradle.properties` alone are insufficient
