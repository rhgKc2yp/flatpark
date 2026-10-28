#!/usr/bin/env bash
set -euo pipefail
# Set to the requested community build repository once its owner is confirmed.
repo=flatpark/beremiz_release
headers=()
[ -z "${GITHUB_TOKEN:-}" ] || headers=(-H "Authorization: Bearer $GITHUB_TOKEN")
release=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/$repo/releases/latest")
# Keep the rebuild revision: 1.6.0-2 must update a 1.6.0-1 install.
jq -e '
  select(.draft == false and .prerelease == false) |
  . as $r |
  ($r.tag_name | ltrimstr("v")) as $version |
  [ $r.assets[] | select(.name == ("beremiz-" + $version + "-x86_64.tar.gz")) ] as $assets |
  if ($assets | length) != 1 then error("Missing or ambiguous x86_64 Beremiz archive")
  else {
    version: $version,
    releaseDate: ($r.published_at[0:10]),
    releaseUrl: $r.html_url,
    sources: [{filename: "beremiz.tar.gz", arch: "x86_64", url: $assets[0].browser_download_url, size: $assets[0].size}]
  } end
' <<< "$release"
