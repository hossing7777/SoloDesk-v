# License tools (seller only — not shipped in the app)

1. `cd tools && dart pub get`
2. `cp keys.json.example keys.json` and put a long random string in `"secret"`.
3. Build the app with the SAME secret:
   - Local: `flutter build apk --release --dart-define=LICENSE_SECRET=<secret>`
   - GitHub Actions: add a repository secret named `LICENSE_SECRET` (Settings → Secrets and variables → Actions).
4. Generate keys: `dart run generate_license.dart 10` — prints keys and appends them to `keys.json`.
5. Send one key per Gumroad sale (Gumroad can also auto-deliver a key list).

## Storing the secret and keys
- `keys.json` is git-ignored. **Back it up** (password manager + offline copy). Losing the secret means
  you can never issue keys that match already-published builds.
- Never commit the secret. Treat it like a signing key.

## Security note
Validation is offline, so the secret is embedded in the compiled app. It stops casual sharing and
key-guessing, but a determined reverse engineer could extract it. Use it for a one-time-purchase indie app,
not for high-value DRM.
