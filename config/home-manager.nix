{ config, pkgs, ... }:

{
  imports = [
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  home-manager.users.alapshin = {
    programs.home-manager.enable = true;

    xdg.configFile."nixpkgs/config.nix".source =
      ./nixpkgs-config.nix;

    home.packages = with pkgs; [
      android-studio
      jetbrains.clion
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
    ];
  };

  environment.systemPackages = with pkgs; [
    home-manager
  ];
}
