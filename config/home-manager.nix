{ config, pkgs, ... }:

let 
  # Define fonts and dotfiles paths as strings.
  # Using strings forces home-manager to create symlinks to original files
  # instead of copying them to nix store. This allows to edit doftiles in-place. 
  # See https://github.com/rycee/home-manager/issues/257 for details.
  fonts = builtins.toString ../fonts;
  dotfiles = builtins.toString ../dotfiles;
in
{
  # Setup home-manager as NixOS module.
  # See https://github.com/rycee/home-manager/issues/417 for details why 
  # fetchGit is used.
  imports = [
    "${builtins.fetchGit { 
      ref = "master"; 
      url = "https://github.com/rycee/home-manager"; 
    }}/nixos"
  ];

  home-manager.users.alapshin = {
    nixpkgs.config = import ./nixpkgs-config.nix;

    services = {
      kbfs.enable = true;
      keybase.enable = true;
      syncthing.enable = true;
      redshift = {
        enable = true;
        provider = "manual";
        latitude = "58.5969";
        longitude = "49.6583";
        extraOptions = [ "-P" "-m randr" ];
      };
    };

    home.packages = with pkgs; [
      home-manager

      jetbrains.jdk
      jetbrains.clion
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
      androidStudioPackages.beta
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
      IDEA_JDK = "${pkgs.jetbrains.jdk}";

      ANDROID_SDK = "$HOME/opt/android-sdk";
      ANDROID_HOME = "$HOME/opt/android-sdk";
      PATH = "$PATH:$ANDROID_SDK:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin";

      # Enforcment of XDG directory structure
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

      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'';
    };
  };
}
