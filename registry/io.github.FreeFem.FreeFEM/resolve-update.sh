#!/usr/bin/env bash
set -euo pipefail
# Match the tested Ubuntu 26.04 binary, not the container export or source archive.
api=https://api.github.com/repos/FreeFem/FreeFem-sources/releases/latest
headers=()
if [ -n "${GITHUB_TOKEN:-}" ]; then headers=(-H "Authorization: Bearer $GITHUB_TOKEN"); fi
curl -fsSL --retry 3 --max-time 60 "${headers[@]}" "$api" | python3 -c '
import json, re, sys
r = json.load(sys.stdin)
v = r["tag_name"].removeprefix("v")
if r.get("draft") or r.get("prerelease") or not re.fullmatch(r"[0-9]+(?:\.[0-9]+)+", v):
    sys.exit("expected a stable FreeFEM release")
assets = [a for a in r["assets"] if a["name"] == "FreeFEM-" + v + "-amd64-ubuntu26.04.deb"]
if len(assets) != 1:
    sys.exit("expected one Ubuntu 26.04 amd64 package")
print(json.dumps({"version": v, "releaseDate": r["published_at"][:10],
    "sources": [{"filename": "freefem.deb", "arch": "x86_64", "url": assets[0]["browser_download_url"]}]}))
'
