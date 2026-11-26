#!/usr/bin/env bash
set -euo pipefail
release="$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} https://api.github.com/repos/microlift/rosemary/releases/latest)"
jq -e '
  (.tag_name | ltrimstr("v")) as $version
  | [.assets[] | select(.name == "Rosemary-\($version)-x86_64.AppImage")] as $a
  | if ($version | length) == 0 or ($a | length) != 1 then error("expected one Rosemary AppImage") else . end
  | {version: $version, releaseDate: .published_at[0:10], sources: [{filename: "rosemary.AppImage", arch: "x86_64", url: $a[0].browser_download_url}]}
' <<<"$release"
