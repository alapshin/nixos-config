#!/usr/bin/env bash

set -euo pipefail

nix shell nixpkgs#sops --command ci/build.sh check
