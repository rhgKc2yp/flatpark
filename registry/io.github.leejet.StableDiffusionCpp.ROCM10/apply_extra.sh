#!/bin/sh
set -eu
# Flatpak runs this offline as root without capabilities on system installs.
cd "${EXTRA_ROOT:-/app/extra}"
[ -f sd.zip ] || { echo "missing extra-data: sd.zip" >&2; exit 1; }
rm -rf stage stable-diffusion
mkdir stage
bsdtar --no-same-owner -xf sd.zip -C stage
# Locate the portable binary directory; the ROCm zip currently uses build/bin.
server="$(find stage -type f -name sd-server)"
[ "$(printf '%s\n' "$server" | wc -l)" -eq 1 ] && [ -n "$server" ] || {
    echo "expected exactly one sd-server executable" >&2; exit 1;
}
payload="$(dirname "$server")"
for binary in sd-cli sd-server; do
    [ -x "$payload/$binary" ] || { echo "missing executable: $binary" >&2; exit 1; }
done
[ -f "$payload/libstable-diffusion.so" ] || { echo "missing stable-diffusion library" >&2; exit 1; }
[ -f "$payload/libggml-hip.so" ] || { echo "missing ROCm backend" >&2; exit 1; }
mv "$payload" stable-diffusion
rm -rf stage sd.zip
