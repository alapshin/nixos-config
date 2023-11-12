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

## Projects used in this configuration
1. [home-manager] - user environment management 
2. [diskio] - declarative disk partitioning
3. [sops-nix] - secrect managment based on sops
4. [lanzaboote] - secure boot support 
5. [nixos-anywhere] - NixOS provisioning via SSH

[nixos]: https://channels.nixos.org/nixos-23.05/latest-nixos-minimal-x86_64-linux.iso
[diskio]: https://github.com/nix-community/disko
[sops-nix]: https://github.com/Mic92/sops-nix
[lanzaboote]: https://github.com/nix-community/lanzaboote
[home-manager]: https://github.com/nix-community/home-manager
[nixos-anywhere]: https://github.com/nix-community/nixos-anywhere

