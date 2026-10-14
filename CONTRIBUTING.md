# Contributing
1. Fork and create a feature branch.
2. Run `flutter pub get`, `bash scripts/fetch_fonts.sh`, then `flutter analyze` and `flutter test` — both must pass.
3. All UI strings go in `lib/l10n/*.arb` (add the key to every language file).
4. Keep code simple and commented; no code generation (no build_runner/Freezed).
5. Open a pull request describing the change and how you tested it.
