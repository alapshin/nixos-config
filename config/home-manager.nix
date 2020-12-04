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

    neovim-konsole = (pkgs.makeDesktopItem {
      icon = "nvim";
      name = "neovimwrapper";
      desktopName = "NeovimKonsole";
      categories = "Utility;TextEditor;";
      exec = "konsole --nofork --dograb --hide-tabbar --hide-menubar --notransparency -e nvim %F";
      mimeType = "MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;";
    });
    keepassxc-autostart = (pkgs.makeAutostartItem { 
      name = "KeePassXC"; 
      package = pkgs.keepassxc; 
      srcPrefix = "org.keepassxc."; 
    });
    thunderbird-autostart = (pkgs.makeAutostartItem { 
      name = "thunderbird"; 
      package = pkgs.thunderbird; 
    });
  in
  {
    nixpkgs.config = import ./nixpkgs-config.nix;

    services = {
      syncthing.enable = true;
      # redshift = {
      #   enable = true;
      #   provider = "manual";
      #   latitude = "58.5969";
      #   longitude = "49.6583";
      #   extraOptions = [ "-P" "-m randr" ];
      # };
    };

    home.packages = with pkgs; [
      home-manager
      neovim-konsole
      keepassxc-autostart
      thunderbird-autostart
    ];

    home.file = {
      ".zshrc".source = "${dotfiles}/zshrc";
      ".p10k.zsh".source = "${dotfiles}/p10k.zsh";
      ".curlrc".source = "${dotfiles}/curlrc";
      ".ssh/config".source = "${dotfiles}/ssh/config";
      ".ideavimrc".source = "${dotfiles}/ideavimrc";
    };

    home.language = {
      address = "ru_RU.UTF-8";
      base = "en_US.UTF-8";
      monetary = "ru_RU.UTF-8";
      paper = "ru_RU.UTF-8";
      time = "en_DK.UTF-8";
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
        "git/config-alar".source = "${dotfiles}/gitconfig-alar";

        "fontconfig".source = ../dotfiles/fontconfig;
        "nixpkgs/config.nix".source = ./nixpkgs-config.nix;
      };
    };

    home.sessionVariables = let 
      dataHome = userConfig.xdg.dataHome;
      cacheHome = userConfig.xdg.cacheHome;
      configHome = userConfig.xdg.configHome;
    in {
      ANDROID_SDK_ROOT = "$HOME/opt/android-sdk";

      # Force some apps to use XDG directories
      AWS_CONFIG_FILE = "${configHome}/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "${configHome}/aws/credentials";
      CARGO_HOME = "${dataHome}/cargo";
      CCACHE_DIR = "${cacheHome}/ccache";
      CCACHE_CONFIGPATH = "${configHome}/ccache.config";
      CUDA_CACHE_PATH = "${cacheHome}/nv";
      DOCKER_CONFIG = "${configHome}/docker";
      GNUPGHOME = "${configHome}/gnupg";
      HTTPIE_CONFIG_DIR = "${configHome}/httpie";
      IPYTHONDIR = "${configHome}/jupyter";
      JUPYTER_CONFIG_DIR = "${configHome}/jupyter";
      MACHINE_STORAGE_PATH = "${dataHome}/docker-machine";
      TIGRC_USER = "${configHome}/tigrc";

      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot="${configHome}"/java -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'';
    };
  };
}
