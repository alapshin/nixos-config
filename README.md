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

* `dotfiles` - Dotfiles symlinked by Home Manager
* `packages` - Local packages or packages not yet in nixpkgs

* `overlays` - Overlays definition
    * `custom.nix` - Overlay with customized packages
    * `packages.nix` - Overlay with local packages

[hm]: https://github.com/nix-community/home-manager
[nixos]: https://channels.nixos.org/nixos-20.09/latest-nixos-minimal-x86_64-linux.iso
