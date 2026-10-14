# SoloDesk

Offline-first client, time and invoice manager for freelancers. Flutter (Material 3), Android only,
10 languages (fa/ar are RTL), PDF invoices, Pro license sold as a one-time payment on Gumroad.

## Requirements
Flutter 3.22.x (Dart 3.4+), Android SDK 34, Java 17.

## Run / build
```bash
flutter pub get                    # also generates lib/l10n/gen (gen-l10n)
bash scripts/fetch_fonts.sh        # downloads Inter + Vazirmatn (static, OFL) into assets/fonts
dart run flutter_launcher_icons    # generates launcher icons from assets/icon/icon.png
flutter run
flutter build apk --release        # build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release  # build/app/outputs/bundle/release/app-release.aab
```
Optional native splash: `dart run flutter_native_splash:create` (overwrites the hand-written splash drawables).

## Rename app / package / icons
- Name: `android:label` in `android/app/src/main/AndroidManifest.xml` and `lib/l10n/*.arb` (`appName`).
- Package: change `applicationId` and `namespace` in `android/app/build.gradle`, move
  `android/app/src/main/kotlin/com/solodesk/freelance`, update the `package` line in both Kotlin files,
  the `.MainActivity`/`.TimerService` names stay relative, and the channel name `com.solodesk.freelance/timer`
  in `MainActivity.kt` + `lib/services/foreground_timer_service.dart`.
- Icons: replace `assets/icon/icon.png` (1024x1024) and `assets/logo.png`, then `dart run flutter_launcher_icons`.

## Build with GitHub Actions (free, no PC needed)
1. Push this folder to a GitHub repository (branch `main`).
2. Open **Actions → Build APK** (runs on every push; or press *Run workflow*).
3. Download the artifacts: `solodesk-universal-apk`, `solodesk-split-apks`, `solodesk-aab`.
4. Add the repo secret `LICENSE_SECRET` (see below) BEFORE building the version you sell.

### Signing
Without a keystore the release build is signed with the debug key (fine for testing, not for the Play Store).
Create `android/key.properties` (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`) for local signed builds.

## License keys (seller)
See [tools/README.md](tools/README.md). Short version:
`cd tools && dart pub get && cp keys.json.example keys.json` → set `secret` → `dart run generate_license.dart 10`.
Build the app with `--dart-define=LICENSE_SECRET=<same secret>` (GitHub secret `LICENSE_SECRET`).

## Activate a Pro key (customer)
Open **More → Upgrade to Pro**, paste the key (`SOLO-XXXXXXXX-XXXXXXXX`), tap **Activate**.
The free plan allows 5 clients and 5 invoices.

> **WARNING (seller):** back up your **Android keystore** and **tools/keys.json** (including the secret).
> Lose the keystore and you can never update the published app; lose the secret and you cannot issue valid keys.

## License
Code: MIT (see LICENSE). Fonts: SIL OFL 1.1 (assets/fonts/*/OFL.txt).

## Support
support@example.com (placeholder — replace before publishing).
