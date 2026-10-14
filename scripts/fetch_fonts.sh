#!/usr/bin/env bash
# Downloads the static fonts used by the app and the PDF engine.
# Idempotent: skips files that already exist. Run from the project root.
set -u
V=assets/fonts/Vazirmatn
I=assets/fonts/Inter
mkdir -p "$V" "$I"

get() { # get <dest> <url>...
  local dest="$1"; shift
  [ -s "$dest" ] && return 0
  for url in "$@"; do
    if curl -fsSL --retry 3 -o "$dest" "$url" && [ -s "$dest" ]; then echo "ok  $dest"; return 0; fi
  done
  rm -f "$dest"; return 1
}

for w in Regular Bold; do
  get "$V/Vazirmatn-$w.ttf" \
    "https://cdn.jsdelivr.net/npm/vazirmatn@33.0.3/fonts/ttf/Vazirmatn-$w.ttf" \
    "https://raw.githubusercontent.com/rastikerdar/vazirmatn/master/fonts/ttf/Vazirmatn-$w.ttf" \
    || { echo "FATAL: cannot download Vazirmatn-$w.ttf (needed for PDF fa/ar)"; exit 1; }
done

for w in Regular Medium Bold; do
  get "$I/Inter-$w.ttf" \
    "https://cdn.jsdelivr.net/gh/rsms/inter@v3.19/docs/font-files/Inter-$w.otf" \
    "https://raw.githubusercontent.com/rsms/inter/v3.19/docs/font-files/Inter-$w.otf" \
    || { echo "warn: Inter-$w unavailable, falling back to Vazirmatn"; \
         cp "$V/Vazirmatn-$([ "$w" = Bold ] && echo Bold || echo Regular).ttf" "$I/Inter-$w.ttf"; }
done
echo "fonts ready"
