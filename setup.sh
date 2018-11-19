#!/usr/bin/env sh

set -e

# Backup existing configuration
if [ -d /etc/nixos ]; then
    cp -r /etc/nixos /etc/nixos.orig
fi

# Cleanup existing configuration
rm -f /etc/nixos/*

# Create symlinks to new configuration
for file in "${PWD}"/config/*; do
    ln -sf "${file}" /etc/nixos/
done
