#!/usr/bin/env sh

# Setup script for NixOS and https://github.com/rycee/home-manager

for file in ${PWD}/config/*.nix; do
  sudo ln -sf ${file} /etc/nixos/
done
