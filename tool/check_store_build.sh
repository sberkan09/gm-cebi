#!/usr/bin/env bash
# Checks that a store App Bundle carries no internal test features and no
# network permission (docs/release.md, docs/store/privacy-policy-*.md).
#
#   tool/check_store_build.sh build/app/outputs/bundle/release/app-release.aab
#   tool/check_store_build.sh --online …   a build with the online scene feature (NC_API_URL):
#                                          the INTERNET permission is then required, not refused
set -euo pipefail
online=0
if [ "${1:-}" = "--online" ]; then online=1; shift; fi
aab=${1:?usage: tool/check_store_build.sh [--online] <app-release.aab>}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
unzip -q "$aab" 'base/lib/*/libapp.so' 'base/manifest/AndroidManifest.xml' -d "$work"

fail=0
# Widget keys that exist only inside `if (kInternalBuild)` branches. With
# GMCEBI_INTERNAL unset/false they are tree-shaken out of the AOT snapshot.
for so in "$work"/base/lib/*/libapp.so; do
  for marker in gm-pack-test-switch; do
    if grep -aq "$marker" "$so"; then
      echo "FAIL: internal marker '$marker' found in ${so#"$work"/}" >&2
      fail=1
    fi
  done
done
# Offline app: the release manifest must not ask for network access, unless this is a build
# with the online scene feature (docs/online-scene.md), which needs it.
has_internet=0
grep -aq 'android.permission.INTERNET' "$work/base/manifest/AndroidManifest.xml" && has_internet=1
if [ "$online" = 0 ] && [ "$has_internet" = 1 ]; then
  echo "FAIL: release manifest requests android.permission.INTERNET (an online build? use --online)" >&2
  fail=1
elif [ "$online" = 1 ] && [ "$has_internet" = 0 ]; then
  echo "FAIL: --online, but the manifest has no INTERNET permission (was NC_API_URL given?)" >&2
  fail=1
fi
# Signed with an upload key, never the debug key (a local build without key.properties).
if keytool -printcert -jarfile "$aab" 2>/dev/null | grep -q 'CN=Android Debug'; then
  echo "FAIL: signed with the debug key; Play rejects it (android/key.properties, docs/release.md)" >&2
  fail=1
fi
if grep -aq 'gmcebi.test' "$work/base/manifest/AndroidManifest.xml"; then
  echo "FAIL: internal test build (application id …gmcebi.test)" >&2
  fail=1
fi
if grep -aq 'com.example' "$work/base/manifest/AndroidManifest.xml"; then
  echo "FAIL: placeholder package name com.example in the manifest" >&2
  fail=1
fi
[ "$fail" = 0 ] && echo "store build checks passed: $aab"
exit "$fail"
