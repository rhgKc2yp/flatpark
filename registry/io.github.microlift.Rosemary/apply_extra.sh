#!/bin/sh
set -eu
cd "${EXTRA_ROOT:-/app/extra}"
for f in rosemary.AppImage appimage-tools.tar.xz; do
  [ -f "$f" ] || { echo "missing extra-data: $f" >&2; exit 1; }
done
bsdtar --no-same-owner -xf appimage-tools.tar.xz
offset="$(appimage-tools/bin/appimage-offset rosemary.AppImage)"
case "$offset" in ''|*[!0-9]*) echo 'invalid AppImage offset' >&2; exit 1;; esac
rm -rf rosemary
appimage-tools/bin/unsquashfs -q -no-xattrs -o "$offset" -d rosemary rosemary.AppImage >/dev/null
[ -x rosemary/AppRun ] && [ -x rosemary/libexec/rosemary ] || { echo 'incomplete Rosemary AppImage' >&2; exit 1; }
rm -rf appimage-tools rosemary.AppImage appimage-tools.tar.xz
