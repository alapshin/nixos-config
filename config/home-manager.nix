{ config, pkgs, ... }:

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

  home-manager.users.alapshin = let
    # Define fonts and dotfiles paths as strings.
    # Using strings forces home-manager to create symlinks to original files
    # instead of copying them to nix store. This allows to edit doftiles in-place. 
    # See https://github.com/rycee/home-manager/issues/257 for details.
    fonts = builtins.toString ../fonts;
    dotfiles = builtins.toString ../dotfiles;
    userConfig = config.home-manager.users.alapshin;
  in
  {
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

    xdg = {
      enable = true;
      dataFile = {
        "fonts/FiraCode".source = "${fonts}/FiraCode";
      };
      configFile = {
        "nvim".source = "${dotfiles}/nvim";

        "tigrc".source = "${dotfiles}/tigrc";
        "git/config".source = "${dotfiles}/gitconfig";

        "fontconfig".source = ../dotfiles/fontconfig;
        "nixpkgs/config.nix".source = ./nixpkgs-config.nix;
      };
    };

    home.sessionVariables = let 
      dataHome = userConfig.xdg.dataHome;
      cacheHome = userConfig.xdg.cacheHome;
      configHome = userConfig.xdg.configHome;
    in {
      ANDROID_HOME = "$HOME/opt/android-sdk";
      ANDROID_NDK_HOME = "$HOME/opt/android-sdk/ndk-bundle";

      # Force some apps to use XDG directories
      AWS_CONFIG_FILE = "${configHome}/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "${configHome}/aws/credentials";
      CARGO_HOME = "${dataHome}/cargo";
      CCACHE_DIR = "${cacheHome}/ccache";
      CCACHE_CONFIGPATH = "${configHome}/ccache.config";
      CUDA_CACHE_PATH = "${cacheHome}/nv";
      DOCKER_CONFIG = "${configHome}/docker";
      GNUPGHOME = "${configHome}/gnupg";
      GRADLE_USER_HOME = "${dataHome}/gradle";
      HTTPIE_CONFIG_DIR = "${configHome}/httpie";
      IPYTHONDIR = "${configHome}/jupyter";
      JUPYTER_CONFIG_DIR = "${configHome}/jupyter";
      MACHINE_STORAGE_PATH = "${dataHome}/docker-machine";
      TIGRC_USER = "${configHome}/tigrc";

      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot="${configHome}"/java -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'';
    };
  };
}
