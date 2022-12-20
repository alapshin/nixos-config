#!/usr/bin/env bash

nix shell nixpkgs#sops --command ci/check.sh
