#!/usr/bin/env bash
# Fills license-number tokens in the site's HTML locally.
# Run from the site root:  bash scripts/fill-licenses.sh
# Numbers are typed at the prompt (not echoed to shell history).
set -euo pipefail
read -rp "Indiana home inspector license #: " HI
read -rp "IDOH radon tester license # (blank to leave the token): " RT
files=$(grep -rl --include=*.html -e '{{HOME_INSPECTOR_LICENSE}}' -e '{{RADON_TESTER_LICENSE}}' . || true)
[ -z "$files" ] && { echo "No tokens found (already filled?)"; exit 0; }
for f in $files; do
  HI="$HI" RT="$RT" python3 - "$f" <<'PY'
import os, sys
p = sys.argv[1]; s = open(p).read()
s = s.replace("{{HOME_INSPECTOR_LICENSE}}", os.environ["HI"])
if os.environ["RT"]:
    s = s.replace("{{RADON_TESTER_LICENSE}}", os.environ["RT"])
open(p, "w").write(s)
PY
  echo "filled: $f"
done
grep -rn --include=*.html -e '{{HOME_INSPECTOR_LICENSE}}' -e '{{RADON_TESTER_LICENSE}}' . && echo "^ tokens still unfilled" || echo "All license tokens filled."
