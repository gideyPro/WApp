# AGENTS.md

## Prerequisites
- Flutter 3.38.0 stable (pinned in CI), SDK >=3.0.0 <4.0.0
- Java 17 required for Android builds

## Localization
- Generated files in `lib/l10n/` are committed; run `flutter gen-l10n` only when editing ARB files

## Configuration
- Default API URL: `https://wavemart.et/api`, override with `--dart-define=API_BASE_URL=<url>`
- Google Fonts are bundled locally; runtime fetching disabled

## Architecture
- State: Riverpod | Navigation: go_router | Local storage: Hive (boxes: `listing_drafts`, `app_preferences`)
- `lib/core/`: Network, theme | `lib/data/`: Models, services | `lib/presentation/`: Providers, screens | `lib/l10n/`: en/am/ti localization

## Commands
- `flutter pub get` (deps)
- `flutter analyze` (lint, uses flutter_lints)
- `flutter run` (dev)
- `flutter build apk --debug` / `--release` (builds)
- No tests exist: skip `flutter test`

## CI
- Manual trigger only; builds/upload APKs

## Notes
- `.kilo/` is Kilo internal; do not modify
