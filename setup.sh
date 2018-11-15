#!/usr/bin/env sh

# Backup existing configuration
if [ -d /etc/nixos ]; then
    mv /etc/nixos /etc/nixos.orig
fi

# Symlink configuration to /etc/nixos
ln -sf "$PWD/nixos" /etc/
