{
  pkgs,
  dotfileDir,
  ...
}: let
  username = "alapshin";
in {
  home-manager.users."${username}" = {
    imports = [
      ./gnupg.nix
      ./shell.nix
      ./plasma.nix
      ./neovim.nix
      ./firefox.nix
      ./thunderbird.nix
    ];

    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      home-manager
      birdtray-autostart
      keepassxc-autostart
    ];

    home.file = {
      ".curlrc".source = "${dotfileDir}/curlrc";
      ".ssh/config".source = "${dotfileDir}/ssh/config";
    };

    home.language = {
      base = "en_US.UTF-8";
      time = "en_DK.UTF-8";
      paper = "en_DK.UTF-8";
      numeric = "en_DK.UTF-8";
      monetary = "en_IE.UTF-8";
      measurement = "en_DK.UTF-8";
    };

    fonts.fontconfig.enable = false;

    xdg = {
      enable = true;
      configFile = {
        "nvim" = {
          source = "${dotfileDir}/nvim";
          recursive = true;
        };
        "fontconfig" = {
          source = "${dotfileDir}/fontconfig";
          recursive = true;
        };

        "git/config".source = "${dotfileDir}/gitconfig";
        "git/config-alar".source = "${dotfileDir}/gitconfig-alar";
        "ideavim/ideavimrc".source = "${dotfileDir}/ideavimrc";
        "latexmk/latexmkrc".source = "${dotfileDir}/latexmkrc";
        "tig/config".source = "${dotfileDir}/tigrc";
        "zsh/p10k.zsh".source = "${dotfileDir}/p10k.zsh";
        "borgmatic/config.yaml".source = "${dotfileDir}/borgmatic.yaml";
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
    home.sessionVariables = {
      EDITOR = "nvim";

      ANDROID_SDK_ROOT = "$HOME/opt/android-sdk";
      # ANDROID_PREFS_ROOT = "$XDG_CONFIG_HOME/android";
      # ANDROID_EMULATOR_HOME = "$XDG_DATA_HOME/android/emulator";

      AWS_CONFIG_FILE = "$XDG_CONFIG_HOME/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "$XDG_CONFIG_HOME/aws/credentials";
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
      GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
      IPYTHONDIR = "$XDG_CONFIG_HOME/jupyter";
      JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";

      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'';
    };
  };
}
