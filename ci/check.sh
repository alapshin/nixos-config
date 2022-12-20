#!/usr/bin/env bash

sops --decrypt --in-place secrets/accounts.json && nix flake check
