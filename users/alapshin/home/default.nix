{
  config,
  dirs,
  myutils,
  pkgs,
  ...
}: let
  hmcfg = config.home-manager.users."${username}";
  username = myutils.extractUsername (builtins.toString ./.);
in {
  imports = [
    ./apps.nix
    ./shell.nix
    ./neovim.nix
    ./firefox.nix
  ];

  home-manager.users."${username}" = {
    home.stateVersion = "22.05";
    home.packages = with pkgs; [
      home-manager
      keepassxc-autostart
      thunderbird-autostart
    ];

    home.file = {
      ".curlrc".source = "${dirs.dotfiles}/curlrc";
      ".ssh/config".source = "${dirs.dotfiles}/ssh/config";
      ".ideavimrc".source = "${dirs.dotfiles}/ideavimrc";
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
      configFile = {
        "nvim" = {
          source = "${dirs.dotfiles}/nvim";
          recursive = true;
        };
        "fontconfig" = {
          source = "${dirs.dotfiles}/fontconfig";
          recursive = true;
        };

        "tig/config".source = "${dirs.dotfiles}/tigrc";
        "git/config".source = "${dirs.dotfiles}/gitconfig";
        "git/config-alar".source = "${dirs.dotfiles}/gitconfig-alar";
        "zsh/p10k.zsh".source = "${dirs.dotfiles}/p10k.zsh";
      };
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "firefox.desktop";
          "text/plain" = "org.kde.kwrite.desktop";
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "x-scheme-handler/mailto" = "thunderbird.desktop";
        };
      };
    };

    # Enforce XDG directories usage for some apps
    home.sessionVariables = let
      homeDir = hmcfg.home.homeDirectory;
      xdgDataHome = hmcfg.xdg.dataHome;
      xdgCacheHome = hmcfg.xdg.cacheHome;
      xdgConfigHome = hmcfg.xdg.configHome;
    in {
      EDITOR = "nvim";

      ANDROID_SDK_ROOT = "${homeDir}/opt/android-sdk";
      # ANDROID_PREFS_ROOT = "${xdgConfigHome}/android";
      # ANDROID_EMULATOR_HOME = "${xdgDataHome}/android/emulator";

      AWS_CONFIG_FILE = "${xdgConfigHome}/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "${xdgConfigHome}/aws/credentials";
      CARGO_HOME = "${xdgDataHome}/cargo";
      CUDA_CACHE_PATH = "${xdgCacheHome}/nv";
      DOCKER_CONFIG = "${xdgConfigHome}/docker";
      GNUPGHOME = "${xdgConfigHome}/gnupg";
      GRADLE_USER_HOME = "${xdgDataHome}/gradle";
      IPYTHONDIR = "${xdgConfigHome}/jupyter";
      JUPYTER_CONFIG_DIR = "${xdgConfigHome}/jupyter";
      MACHINE_STORAGE_PATH = "${xdgDataHome}/docker-machine";

      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot=${xdgConfigHome}/java -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'';
    };
  };
}
