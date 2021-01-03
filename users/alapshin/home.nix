{ config, dirs, myutils, pkgs, ... }:
let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  environment = {
    sessionVariables = {
      # These are the defaults, and xdg.enable does set them, but due to load
      # order, they're not set before environment.variables are set, which could
      # cause race conditions.
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
    };
    variables = {
      ANDROID_SDK_ROOT = "$HOME/opt/android-sdk";
      # Force some apps to use XDG directories
      ANDROID_PREFS_ROOT = "$XDG_CONFIG_HOME/android";
      ANDROID_EMULATOR_HOME = "$XDG_DATA_HOME/android/emulator";

      AWS_CONFIG_FILE = "$XDG_CONFIG_HOME/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "$XDG_CONFIG_HOME/aws/credentials";
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
      GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
      GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
      IPYTHONDIR = "$XDG_CONFIG_HOME/jupyter";
      JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
      MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker-machine";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";

      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'';
    };
  };

  home-manager.users."${username}" = {
    services = {
      syncthing.enable = true;
    };

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
        "nvim".source = "${dirs.dotfiles}/nvim";

        "tig/config".source = "${dirs.dotfiles}/tigrc";
        "git/config".source = "${dirs.dotfiles}/gitconfig";
        "git/config-alar".source = "${dirs.dotfiles}/gitconfig-alar";
        "fontconfig" = { source = "${dirs.dotfiles}/fontconfig"; recursive = true; };
        "zsh/.zshrc".source = "${dirs.dotfiles}/zshrc";
        "zsh/p10k.zsh".source = "${dirs.dotfiles}/p10k.zsh";
      };
    };
  };
}
