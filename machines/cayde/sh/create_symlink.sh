#!/usr/bin/env bash
# Create symlinks in the target dir from files copied to the clipboard.
# Usage: paste-as-symlink.sh <destination-dir>
set -euo pipefail

dest="${1:-.}"

# Thunar copies files using the gnome-copied-files target; fall back to uri-list
data="$(xclip -selection clipboard -t x-special/gnome-copied-files -o 2>/dev/null || true)"
[ -z "$data" ] && data="$(xclip -selection clipboard -t text/uri-list -o 2>/dev/null || true)"
[ -z "$data" ] && exit 0

urldecode() { local s="$1"; printf '%b' "${s//%/\\x}"; }

while IFS= read -r line; do
    case "$line" in copy|cut|"") continue ;; esac
    path="${line#file://}"
    path="$(urldecode "$path")"
    path="${path%$'\r'}"
    [ -e "$path" ] && ln -s "$path" "$dest"/
done <<< "$data"