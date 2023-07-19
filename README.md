NixOS configuration done using flakes

### Installation

1. Boot into [NixOS][nixos].
2. Partion your disks.
3. Mount root partition into `/mnt`.
4. Clone this repository and `cd` into it.
5. Install using command `nixos-install --root /mnt --flake '.#XYZ'`, where `XYZ`
is hostname of machine with appropriate config.
6. Reboot.

### Structure
* `flake.nix` - flake file
* `configuration.nix` - common configuration

* `hosts` - host specific configuration
* `users` - user specific configuration + [home-manager][hm] configuration
* `dotfiles` - Dotfiles used by home-manager
* `overlays` - Overlay definition
* `packages` - Custom packages not yet in nixpkgs
* `secrets` - Secrets managed by [sops-nix][sops-nix]

[nixos]: https://channels.nixos.org/nixos-23.05/latest-nixos-minimal-x86_64-linux.iso
[sops-nix]: https://github.com/Mic92/sops-nix
[home-manager]: https://github.com/nix-community/home-manager
