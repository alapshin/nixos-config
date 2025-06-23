#!/usr/bin/env bash

set -euo pipefail
shopt -s globstar

command=$1
hostname=${2:-}
username=${3:-}
remote_host=${3:-}

function check {
    decrypt-build-secrets "users/alapshin" &&
        nix flake check
}

function build {
    decrypt-build-secrets "users/alapshin"
    nix build ".#nixosConfigurations.${hostname}.config.system.build.toplevel"
}

function update {
    nix flake update
}

function clean-store {
    nix store gc --verbose
}

function switch-home {
    decrypt-build-secrets "users/${username}" &&
        nh home switch --configuration "${username}@${hostname}" .
}

function switch-system {
    decrypt-build-secrets "users/alapshin" &&
        nh os switch ".#nixosConfigurations.${hostname}"
}

function deploy-remote {
    nh os switch \
        --build-host "${remote_host}" \
        --target-host "${remote_host}" \
        ".#nixosConfigurations.${hostname}"
}

function install-remote {
    decrypt-build-secrets "hosts/${hostname}"

    sshdir="hosts/${hostname}/secrets/build/openssh"
    chmod 600 "${sshdir}"/**/*key
    chmod 644 "${sshdir}"/**/*key.pub

    luks_password_file="hosts/${hostname}/secrets/build/luks/key.txt"

    nix run github:nix-community/nixos-anywhere -- \
        --flake ".#${hostname}" \
        --extra-files "${sshdir}" \
        --disk-encryption-keys /tmp/disk.key "${luks_password_file}" \
        "${remote_host}"
}

function sops-update-keys {
    readarray -t encrypted_files <<<"$(
        grep \
            --recursive \
            --exclude-dir="ci" \
            --exclude-dir=".git" \
            --files-with-matches \
            --regexp "unencrypted_suffix"
    )"
    for f in "${encrypted_files[@]}"; do
        sops updatekeys --yes "${f}"
    done
}

# Reset build-time secrets
function reset-build-secrets {
    subdir=$1
    git restore "${subdir}"/secrets/build/
}

# Encrypt build-time secrets
function encrypt-build-secrets {
    subdir=$1
    sops --encrypt --in-place "${subdir}"/build/secrets/**/*
}

# Decrypt build-time secrets
function decrypt-build-secrets {
    subdir=$1

    # Find all build-time secrets under specified subdirectory
    readarray -t encrypted_files <<<"$(
        grep \
            --regexp "unencrypted_suffix" \
            --recursive \
            --exclude-dir="ci" \
            --exclude-dir=".git" \
            --files-with-matches \
            "${subdir}"/secrets/build/
    )"

    trap "reset-build-secrets ${subdir}" EXIT
    for f in "${encrypted_files[@]}"; do
        sops --decrypt --in-place "${f}"
    done
}

case $command in
check)
    check
    ;;
build)
    build
    ;;
update)
    update
    ;;
clean-store)
    clean-store
    ;;
switch-home)
    switch-home
    ;;
switch-system)
    switch-system
    ;;
deploy-remote)
    deploy-remote
    ;;
install-remote)
    install-remote
    ;;
sops-update-keys)
    sops-update-keys
    ;;
*)
    echo -n "Unknown command $command" && exit 1
    ;;
esac
