#!/usr/bin/env bash

set -euo pipefail

nix shell nixpkgs#sops --command ci/check.sh
