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

      AWS_CONFIG_FILE = "$XDG_CONFIG_HOME/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "$XDG_CONFIG_HOME/aws/credentials";
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      CCACHE_DIR = "$XDG_CACHE_HOME/ccache";
      CCACHE_CONFIGPATH = "$XDG_CONFIG_HOME/ccache.config";
      CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
      GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
      GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
      HTTPIE_CONFIG_DIR = "$XDG_CONFIG_HOME/httpie";
      IPYTHONDIR = "$XDG_CONFIG_HOME/jupyter";
      JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
      MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker-machine";
      TIGRC_USER = "$XDG_CONFIG_HOME/tigrc";
      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java'';
    };
  };

  environment.systemPackages = with pkgs; [
    home-manager
  ];
}
