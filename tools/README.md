# License tools (seller only — not shipped in the app)

## Primary method: Master License Key
SoloDesk unlocks Pro when the user enters ONE fixed Master License Key
(format `SOLO-XXXXXXXX-XXXXXXXX-XXXXXXXX`). Every customer gets the same key.
There is no server, no per-customer tracking and no LICENSE_SECRET involved.

- The key is rebuilt at runtime in `lib/services/license_service.dart` from XOR-encoded
  pieces (`_pieceOne`, `_pieceTwo`, `_pieceThree`). Dashes, spaces and letter case are ignored.
- Keep your key in a password manager and on your Gumroad delivery page. Do NOT commit it
  in plain text anywhere (README, issues, commit messages).

### If the Master Key leaks — change it
1. Generate a new key, 3 groups of 8 characters from `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`.
   For example, in Python:
```python
   import secrets
   A = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
   g = ["".join(secrets.choice(A) for _ in range(8)) for _ in range(3)]
   print("SOLO-" + "-".join(g))
   for s in g: print([ord(c) ^ 0x5A for c in s])
```
2. Paste the three printed lists into `_pieceOne`, `_pieceTwo` and `_pieceThree` in
   `lib/services/license_service.dart` (the mask `0x5A` stays the same).
3. Commit and push to `main`. GitHub Actions rebuilds the APK/AAB automatically.
4. Publish the new build and send the new key to customers.
   Note: users on the old build keep working. Users who update will be asked for the new key,
   because the stored key is re-validated at every launch.

### Warning: offline validation can be reverse-engineered
The key is checked on the device. Splitting and XOR-encoding it only stops casual copying;
someone who decompiles the APK can still recover it. This is an acceptable trade-off for a
one-time-purchase indie app, not for high-value DRM.

## Secondary method: per-customer HMAC keys (optional, still supported)
Keys of the form `SOLO-XXXXXXXX-XXXXXXXX` signed with a secret are still accepted as a fallback.
Only use this if you later want individual keys:

1. `cd tools && dart pub get`
2. `cp keys.json.example keys.json` and set a long random `"secret"`.
3. Build the app with the SAME secret: `flutter build apk --release --dart-define=LICENSE_SECRET=<secret>`.
   (The GitHub workflow no longer passes this flag; add it back to `build.yml` if you use HMAC keys.)
4. `dart run generate_license.dart 10` prints keys and appends them to `keys.json`.

Without a `LICENSE_SECRET` build flag, HMAC keys are checked against a public default secret,
so treat them as disabled. `keys.json` is git-ignored — back it up if you use this method.
