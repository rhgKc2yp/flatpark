#!/bin/sh
set -eu
# Runs offline in the runtime, including as root with no capabilities.
cd "${EXTRA_ROOT:-/app/extra}"
[ -f freefem.deb ] || { echo 'missing freefem.deb' >&2; exit 1; }
mkdir stage support
bsdtar -xOf freefem.deb 'data.tar*' | bsdtar --no-same-owner -xf - -C stage
[ -x stage/usr/local/bin/FreeFem++ ] || { echo 'FreeFem++ missing from upstream package' >&2; exit 1; }
[ -x stage/usr/local/bin/ffglut ] || { echo 'ffglut missing from upstream package' >&2; exit 1; }
# Discover the versioned resources, and reject ambiguous or incomplete layouts.
set -- stage/usr/local/lib/ff++/*
[ "$#" -eq 1 ] && [ -d "$1/idp" ] && [ -d "$1/lib" ] || {
    echo 'expected one FreeFEM resource directory' >&2; exit 1;
}
[ -f "stage/usr/local/share/FreeFEM/${1##*/}/examples/tutorial/Laplace.edp" ] || {
    echo 'upstream Laplace example missing' >&2; exit 1;
}
mv stage/usr/local freefem
# Extract only explicitly pinned support packages; no package manager runs here.
for deb in libhdf5-310.deb libsz2.deb libaec0.deb libglut3.12.deb libglu1-mesa.deb \
    libcurl4.deb librtmp1.deb libssh2-1.deb libgssapi-krb5-2.deb libkrb5-3.deb \
    libk5crypto3.deb libkrb5support0.deb libldap-2.5-0.deb libsasl2-2.deb \
    libnettle8.deb libhogweed6.deb libkeyutils1.deb; do
    [ -f "$deb" ] || { echo "missing $deb" >&2; exit 1; }
    bsdtar -xOf "$deb" 'data.tar*' | bsdtar --no-same-owner -xf - -C support
    rm "$deb"
done
[ -f support/usr/lib/x86_64-linux-gnu/libhdf5_serial.so.310 ] || {
    echo 'HDF5 library missing' >&2; exit 1;
}
[ -f support/usr/lib/x86_64-linux-gnu/libcurl.so.4 ] || {
    echo 'versioned curl library missing' >&2; exit 1;
}
rm -rf stage freefem.deb
