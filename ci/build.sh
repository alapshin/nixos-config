#!/usr/bin/env bash

set -euo pipefail

command=$1
flake_uri=${2:-}
target_host=${3:-}

secret_files=(
    "secrets/accounts.json"
)

function reset {
    for f in "${secret_files[@]}"; do
        git restore "${f}"
    done;

}

function encrypt {
    for f in "${secret_files[@]}"; do
        sops --encrypt --in-place "${f}"
    done;
}

function decrypt {
    for f in "${secret_files[@]}"; do
        sops --decrypt --in-place "${f}"
    done;
}

function check {
    decrypt
    nix flake check
}

function update {
    nix flake update
}

function home-switch {
    decrypt
    home-manager switch --flake "${flake_uri}"
}

function system-switch {
    echo "$0"
    decrypt
    sudo nixos-rebuild switch --flake "${flake_uri}"
}

function remote-deploy {
    decrypt
    nixos-rebuild switch --flake "${flake_uri}" --target-host "${target_host}"
}

trap reset EXIT

case $command in
    check)
        check
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
    *)
        echo -n "Unknown command $command"
        ;;
esac
