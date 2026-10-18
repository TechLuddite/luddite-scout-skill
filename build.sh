#!/bin/sh
# Packages SKILL.md, LICENSE and bin/scout as dist/luddite-scout.skill, a zip
# with one folder, luddite-scout/, as Claude Code and the Claude apps expect.
# bin/scout is downloaded from TechLuddite/Luddite-Scout at the commit in
# scout.lock and must match the SHA-256 there. Set SCOUT to a local copy to
# skip the download; the hash check still applies. File times come from the
# last commit, so the same commit gives the same zip.
set -eu

root=$(cd "$(dirname "$0")" && pwd)
out="$root/dist"
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT

commit=$(sed -n 's/^commit=\([0-9a-f]\{40\}\)$/\1/p' "$root/scout.lock")
want=$(sed -n 's/^sha256=\([0-9a-f]\{64\}\)$/\1/p' "$root/scout.lock")
[ -n "$commit" ] && [ -n "$want" ] || { echo "scout.lock is malformed" >&2; exit 1; }

skill="$stage/luddite-scout"
mkdir -p "$skill/scripts" "$out"
if [ -n "${SCOUT:-}" ]; then
  cp "$SCOUT" "$skill/scripts/scout"
else
  curl -q -sS --fail --proto '=https' --max-time 60 --max-filesize 2097152 \
    -o "$skill/scripts/scout" -- "https://raw.githubusercontent.com/TechLuddite/Luddite-Scout/$commit/bin/scout"
fi
got=$(sha256sum "$skill/scripts/scout" | cut -d' ' -f1)
[ "$got" = "$want" ] || { echo "bin/scout SHA-256 $got does not match scout.lock" >&2; exit 1; }

cp "$root/SKILL.md" "$skill/SKILL.md"
cp "$root/LICENSE" "$skill/LICENSE"
chmod 644 "$skill/SKILL.md" "$skill/LICENSE"
chmod 755 "$skill/scripts/scout"

epoch=$(git -C "$root" log -1 --format=%ct 2>/dev/null || echo 315532800)
find "$skill" -exec touch -h -d "@$epoch" {} +

rm -f "$out/luddite-scout.skill"
(cd "$stage" && find luddite-scout | LC_ALL=C sort | TZ=UTC zip -X -q -@ "$out/luddite-scout.skill")
echo "$out/luddite-scout.skill"
