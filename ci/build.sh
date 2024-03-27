#!/usr/bin/env bash

set -euo pipefail

command=$1
hostname=${2:-}
target_host=${3:-}

declare -A build_secrets
build_secrets["common"]=(
    "secrets/accounts.json"
)

build_secrets["server"]=(
    "openssh/etc/ssh/ssh_host_rsa_key"
    "openssh/etc/ssh/ssh_host_ed25519_key"
)

function reset {
    hostname=$1
    git restore "hosts/${hostname}/secrets/build/"

}

function encrypt {
    hostname=$1
    sops --encrypt --in-place "hosts/${hostname}/secrets/**/*"
}

function decrypt {
    hostname=$1
    trap "reset ${hostname}"  EXIT
    sops --decrypt --in-place "hosts/${hostname}/secrets/**/*"
}

function check {
    decrypt
    nix flake check
}

function clean {
    nix store gc --verbose
}

function update {
    nix flake update
}

function home-switch {
    decrypt
    home-manager switch --flake ".#${hostname}"
}

function system-switch {
    decrypt
    sudo nixos-rebuild switch --flake ".#${hostname}"
}

function remote-deploy {
    decrypt
    nixos-rebuild switch --flake ".#${hostname}" --target-host "${target_host}"
}

function remote-install {
    decrypt
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
