#!/usr/bin/env bash
set -euo pipefail

# This script runs inside the cloned ImmortalWrt source tree.
# Keep the initial build close to upstream.
#
# Examples for later:
# - add third-party feeds/packages
# - change default LAN IP / hostname
# - install themes
# - apply a device-specific patch
#
# Do not modify the XG-040G-MD NAND/UBI partition layout here unless you
# intentionally maintain a matching bootloader and recovery procedure.

echo "No extra source-tree customization enabled."
