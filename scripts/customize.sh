#!/usr/bin/env bash
set -euo pipefail

# This script runs inside the cloned ImmortalWrt source tree.
# Keep NAND/UBI layout untouched; only add runtime packages here.

remove_matches() {
  local pattern="$1"
  find ./package ./feeds/luci ./feeds/packages \
    -maxdepth 4 -type d -iname "*${pattern}*" 2>/dev/null \
    -print -exec rm -rf {} + || true
}

clone_direct() {
  local target="$1"
  local repo="$2"
  local branch="$3"

  remove_matches "$target"
  git clone --depth=1 --single-branch --branch "$branch" \
    "https://github.com/${repo}.git" "./package/${target}"
}

import_openclash() {
  local tmp
  tmp="$(mktemp -d)"
  remove_matches "openclash"

  git clone --depth=1 --single-branch --branch dev \
    https://github.com/vernesong/OpenClash.git "$tmp/OpenClash"

  local src
  src="$(find "$tmp/OpenClash" -maxdepth 3 -type d -name 'luci-app-openclash' | head -n1)"
  if [ -z "$src" ]; then
    echo "ERROR: luci-app-openclash directory not found in vernesong/OpenClash"
    exit 1
  fi

  cp -a "$src" ./package/luci-app-openclash
  rm -rf "$tmp"
}

import_viking_packages() {
  # Bingoguo/VIKINGYFY packages provide GecoosAC and the WOL LuCI app.
  # The WOL package was renamed from luci-app-wolplus to luci-app-wolultra.
  remove_matches "gecoosac"
  remove_matches "luci-app-wolplus"
  remove_matches "luci-app-wolultra"
  remove_matches "luci-app-timewol"
  rm -rf ./package/viking-packages

  git clone --depth=1 --single-branch --branch main \
    https://github.com/VIKINGYFY/packages.git ./package/viking-packages
}

echo "Importing third-party packages used by the GENERAL package set..."

import_openclash
clone_direct "luci-app-lucky" "sirpdboy/luci-app-lucky" "main"
import_viking_packages
clone_direct "luci-app-airoha-npu" "bingoguo93/luci-app-airoha-npu" "main"

# Force package metadata to be regenerated after adding/removing package trees.
rm -rf ./tmp

echo "Third-party package import completed."
