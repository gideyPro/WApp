# AGENTS.md

## Repository layout
- Root: Flutter mobile app
- `WaveMart/`: Laravel 12 backend
- `design-system/`: UI design system (standalone)

## Prerequisites
- Flutter 3.38.0 stable (pinned in CI), SDK >=3.0.0 <4.0.0
- Java 17 for Android builds
- PHP 8.2+, MySQL for backend

## Flutter app
- State: Riverpod | Navigation: go_router | Local: Hive (`listing_drafts`, `app_preferences`) + `flutter_secure_storage` (auth tokens)
- Firebase: `firebase_options.dart` committed; run `flutterfire configure` to regenerate
- Google Fonts bundled locally; runtime fetching disabled (`GoogleFonts.config.allowRuntimeFetching = false`)
- Orientations locked to portrait

### Commands
| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install deps |
| `flutter analyze` | Lint (uses flutter_lints) |
| `flutter run --dart-define=API_BASE_URL=<url>` | Dev with custom API URL |
| `flutter build apk --debug` | Debug APK |
| `flutter build apk --release` | Release APK |
| `dart run build_runner build --delete-conflicting-outputs` | Codegen (Hive adapters) |

### Localization
- `pubspec.yaml` has `generate: true` → `flutter gen-l10n` runs automatically on build/run
- Source ARBs: `lib/l10n/app_{en,am,ti}.arb`; generated Dart files are committed
- Tigrinya falls back to Amharic Material/Widgets/Cupertino localizations (see `main.dart`)

### No test suite
- No Flutter tests exist; verify changes manually

## Backend (Laravel 12)
- Auth: Sanctum + OTP (passwordless) | DB: MySQL
- `WaveMart/.env` required (DB, Chapa, Pusher, Firebase)
- All API routes in `routes/api.php` (prefix `/api`)
- API endpoint reference in `lib/core/network/api_constants.dart`

### Commands
| Command | Purpose |
|---------|---------|
| `composer install` | Install PHP deps |
| `composer run setup` | Full setup: install, `.env` copy, key:generate, migrate, npm build |
| `composer run dev` | Dev server + queue + logs + Vite concurrently |
| `composer run test` | Config clear + phpunit (uses SQLite `:memory:`) |
| `vendor/bin/phpunit` | Or directly (same as `composer run test`) |
| `./vendor/bin/pint` | Laravel Pint (PSR-12 style fixer) |

## CI
- Manual trigger only (GitHub Actions `workflow_dispatch`)
- Builds debug/release APKs; uploads as artifacts

## API call reference
See `API_CALL.md` for cURL examples with test tokens, conference flow, etc.

## Notes
- `.kilo/`, `.gemini/`, `.qwen/` are internal agent dirs; do not modify
- `.opencode/skills/` contains OpenCode skills; do not modify
