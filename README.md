NixOS configuration for my workstation

### Installation
```
git clone https://github.com/alapshin/nixos-config
cd nixos-config
sudo ./setup.sh # This will replace configuration files in /etc/nixos
```

### Structure
* `config` - NixOS configuration files
    * `overlays` - Overlays definition
        * `local.nix` - Overlay with local packages
        * `unstable.nix` - Unstable overlay with packages from `nixpkgs-unstable`

* `pkgs` - Local packages definitions
* `fonts` - Custom fonts not available from nixpkgs
* `dotfiles` - Dotfiles symlinked by Home Manager
