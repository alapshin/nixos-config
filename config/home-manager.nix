{ config, pkgs, ... }:

let 
  fonts = builtins.toString ../fonts;
  dotfiles = builtins.toString ../dotfiles;
in
{
  imports = [
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  home-manager.users.alapshin = {
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      android-studio
      jetbrains.clion
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
    ];

    home.file = {
      ".zshrc".source = "${dotfiles}/zshrc";
      ".curlrc".source = "${dotfiles}/curlrc";
      ".ssh/config".source = "${dotfiles}/ssh/config";
    };

    xdg.dataFile = {
      "fonts/FiraCode".source = "${fonts}/FiraCode";
    };

    xdg.configFile = {
      "nvim".source = "${dotfiles}/nvim";

      "tigrc".source = "${dotfiles}/tigrc";
      "git/config".source = "${dotfiles}/gitconfig";

      "fontconfig".source = ../dotfiles/fontconfig;
      "nixpkgs/config.nix".source = ./nixpkgs-config.nix;
    };

    home.sessionVariables = {
      TIGRC_USER = "$XDG_CONFIG_HOME/tigrc";
    };
  };

  environment.systemPackages = with pkgs; [
    home-manager
  ];
}
