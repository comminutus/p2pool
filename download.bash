#!/usr/bin/env bash
set -euo pipefail
set -x
function _gpg() {
    gpg --batch "$@"
}


function _wget() {
    wget -q "$@"
}

# Find archive filename
platform="$(uname -a | awk '{print tolower($1)}')"
arch="$(uname -m | sed 's/x86_64/x64/g')"
archive_filename="p2pool-v${P2POOL_VERSION}-$platform-$arch.tar.gz"

# Download archive and hashes
_wget "$BASE_ARCHIVE_URL/sha256sums.txt.asc" "$BASE_ARCHIVE_URL/$archive_filename"

# Import signing key
_gpg --import SChernykh.asc

# Verify archive hashes
_gpg --verify sha256sums.txt.asc

# Verify archive
hash="$(grep "$archive_filename" sha256sums.txt.asc -A 2 | sed -n '3p' | sed 's/\r$//' | awk '{print tolower($2)}')"
echo "$hash" "$archive_filename" | sha256sum -c

mkdir -p "$DIST_DIR" archive
tar -x --strip-components 1 -C archive -f "$archive_filename"
cp archive/p2pool "$DIST_DIR"
