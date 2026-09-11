#!/usr/bin/env bash
# XNT-76. Case-insensitive scan for leftover Nextcloud brand colours.
#
# Background: the ad-hoc scans used to sign off XNT-59 were case-sensitive and
# ran against the compiled Assets.car, which stores colours in a form the naive
# byte scan never matched. Both gaps produced false "clean" results and let the
# changelog-avatar and folder imagesets ship with #0082c9 still in them.
#
# This scan therefore:
#   - greps SOURCE, never the compiled Assets.car
#   - matches case-insensitively (-i), so 0082C9 and 0082c9 both hit
#
# Shipped-target hits fail the build. Hits outside the shipped target (docs,
# unit-test fixtures) are reported as warnings: some are legitimate, because
# the tests assert Nextcloud *server*-provided colours, which are not branding.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Nextcloud brand blues: primary, dark variant, element variant.
PATTERN='0082c9|00679e|006aa3'

SHIPPED_DIR="NextcloudTalk"

status=0

echo "==> Scanning shipped target ($SHIPPED_DIR) for Nextcloud brand colours"
if shipped=$(grep -rIniE "$PATTERN" "$SHIPPED_DIR" 2>/dev/null); then
    echo "FAIL: Nextcloud brand colour found in shipped source:"
    echo "$shipped"
    status=1
else
    echo "OK: no Nextcloud brand colours in $SHIPPED_DIR"
fi

echo
echo "==> Scanning remaining tracked files (warnings only)"
others=$(git ls-files -z \
    | grep -zvE "^($SHIPPED_DIR|Pods)/" \
    | xargs -0 grep -IniE "$PATTERN" 2>/dev/null || true)
if [ -n "$others" ]; then
    echo "WARNING: brand colour present outside the shipped target:"
    echo "$others"
    echo
    echo "Review each: unit-test fixtures asserting server-supplied colours are"
    echo "expected; docs/ and marketing assets are genuine rebrand leftovers."
else
    echo "OK: nothing outside the shipped target"
fi

exit "$status"
