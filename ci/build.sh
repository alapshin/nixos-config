#!/usr/bin/env bash

set -euo pipefail
shopt -s globstar

command=$1
hostname=${2:-}
username=${3:-}
remote_host=${3:-}

function check {
	decrypt-build-secrets "modules/users/alapshin" &&
		nix flake check --no-build
}

function update {
	nix flake update
}

function clean-store {
	nh clean all --keep 5
}

# NixOS commands
function nixos-build {
	decrypt-build-secrets "modules/users/alapshin" &&
		nh os build --hostname "${hostname}" "$PWD"
}

function nixos-switch {
	decrypt-build-secrets "modules/users/alapshin" &&
		nh os switch --hostname "${hostname}" "$PWD"
}

# Darwin commands
function darwin-build {
	decrypt-build-secrets "modules/users/alapshin" &&
		nh darwin build --hostname "${hostname}" "$PWD"
}

function darwin-switch {
	decrypt-build-secrets "modules/users/alapshin" &&
		nh darwin switch --hostname "${hostname}" "$PWD"
}

# Home-manager commands
function home-build {
	decrypt-build-secrets "modules/users/${username}" &&
		nh home build --configuration "${username}@${hostname}" "$PWD"
}

function home-switch {
	decrypt-build-secrets "modules/users/${username}" &&
		nh home switch --configuration "${username}@${hostname}" "$PWD"
}

# Keep for backward compatibility
function build {
	nixos-build
}

function remote-switch {
	# Broken https://github.com/nix-community/nh/issues/308
	# nh os switch \
	# 	--hostname "${hostname}" \
	# 	--build-host "${remote_host}" \
	# 	--target-host "${remote_host}" "$PWD"
	nixos-rebuild switch \
		--no-reexec \
		--use-substitutes \
		--build-host "${remote_host}" \
		--target-host "${remote_host}" \
		--flake "$PWD#${hostname}"
}

function remote-install {
	decrypt-build-secrets "hosts/${hostname}"

	sshdir="hosts/${hostname}/secrets/build/openssh"
	chmod 600 "${sshdir}"/**/*key
	chmod 644 "${sshdir}"/**/*key.pub

	luks_password_file="hosts/${hostname}/secrets/build/luks/key.txt"

	# kexec into the NixOS installer first
	nix run github:nix-community/nixos-anywhere -- \
		--phases kexec \
		--flake ".#${hostname}" \
		"${remote_host}"

	# Inject GOPROXY into the post-kexec installer's nix config
	ssh "${remote_host}" -- \
		'mkdir -p ~/.config/nix && printf "extra-experimental-features = configurable-impure-env\nimpure-env = GOPROXY=https://goproxy.cn,direct\n" >> ~/.config/nix/nix.conf'

	# Run the remaining phases: disko, install, reboot
	nix run github:nix-community/nixos-anywhere -- \
		--phases disko,install,reboot \
		--flake ".#${hostname}" \
		--extra-files "${sshdir}" \
		--disk-encryption-keys /tmp/disk.key "${luks_password_file}" \
		--generate-hardware-config nixos-facter "hosts/${hostname}/facter.json" \
		"${remote_host}"
}

function sops-update-keys {
	readarray -t encrypted_files <<<"$(
		grep \
			--regexp '"sops":' \
			--recursive \
			--exclude-dir="ci" \
			--exclude-dir=".git" \
			--files-with-matches
	)"
	for f in "${encrypted_files[@]}"; do
		echo "Re-keying ${f}"
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
			--regexp '"sops":' \
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

if declare -f "$command" >/dev/null; then
	"$command"
else
	echo "Unknown command $command" && exit 1
fi
