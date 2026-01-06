Flake-based NixOS configs for my machines

## Structure
* `flake.nix` - flake file
* `configuration.nix` - common configuration

* `hosts` - host configuration
    * `hosts/secrets*` - [sops-nix] secrets
* `users` - user configuration
    * `users/home` - [home-manager] configuration
* `modules` - custom NixOS modules
* `packages` - custom Nix packages
* `overlays` - overlays definition

* `dotfiles` - dotfiles to be symlinked by [home-manager]

## Projects used in this configuration
1. [diskio] - declarative disk partitioning
2. [sops-nix] - secret management based on sops
3. [lanzaboote] - secure boot support 
4. [nixos-anywhere] - NixOS provisioning via SSH
5. [home-manager] - user environment management 

[diskio]: https://github.com/nix-community/disko
[sops-nix]: https://github.com/Mic92/sops-nix
[lanzaboote]: https://github.com/nix-community/lanzaboote
[home-manager]: https://github.com/nix-community/home-manager
[nixos-anywhere]: https://github.com/nix-community/nixos-anywhere
