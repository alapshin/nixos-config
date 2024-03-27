#!/usr/bin/env bash

set -euo pipefail
shopt -s globstar

command=$1
hostname=${2:-}
username=${2:-}
target_host=${3:-}

function check {
    decrypt-build-secrets "users/alapshin"
    nix flake check
}

function clean {
    nix store gc --verbose
}

function update {
    nix flake update
}

function home-switch {
    decrypt-build-secrets "users/${username}"
    home-manager switch --flake ".#${username}"
}

function system-switch {
    decrypt-build-secrets "users/alapshin"
    sudo nixos-rebuild switch --flake ".#${hostname}"
}

function remote-deploy {
    nixos-rebuild switch --flake ".#${hostname}" --target-host "${target_host}"
}

function remote-install {
    decrypt-build-secrets "hosts/${hostname}"
    nix run github:nix-community/nixos-anywhere --\
        --extra-files "host/${hostname}/secrets/openssh" --flake ".#${hostname}" "${target_host}"
}

function sops-update-keys {
    readarray -t encrypted_files <<< "$(grep \
        --recursive \
        --exclude-dir="ci" \
        --exclude-dir=".git" \
        --files-with-matches \
        --regexp "unencrypted_suffix" \
        )"
    for f in "${encrypted_files[@]}"; do
        sops updatekeys --yes "${f}"
    done
}

# Reset build-time secrets
function reset-build-secrets {
    prefix=$1
    git restore **/${prefix}/secrets/build/
}

# Encrypt build-time secrets
function encrypt-build-secrets {
    prefix=$1
    sops --encrypt --in-place **/${prefix}/build/secrets/**/*
}

# Decrypt build-time secrets
function decrypt-build-secrets {
    prefix=$1
    trap "reset-build-secrets ${prefix}"  EXIT
    sops --decrypt --in-place **/${prefix}/secrets/build/**/*
}

case $command in
    check)
        check
        ;;
    clean)
        clean
        ;;
    update)
        update
        ;;
    home-switch)
        home-switch
        ;;
    system-switch)
        system-switch
        ;;
    remote-deploy)
        remote-deploy
        ;;
    remote-install)
        remote-install
        ;;
    sops-update-keys)
        sops-update-keys
        ;;
    *)
        echo -n "Unknown command $command"
        ;;
esac
