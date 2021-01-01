{ config, dotfiles, pkgs, ... }:

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
      AWS_CONFIG_FILE = "$XDG_CONFIG_HOME/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "$XDG_CONFIG_HOME/aws/credentials";
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
      GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
      HTTPIE_CONFIG_DIR = "$XDG_CONFIG_HOME/httpie";
      IPYTHONDIR = "$XDG_CONFIG_HOME/jupyter";
      JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
      MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker-machine";
      TIGRC_USER = "$XDG_CONFIG_HOME/tigrc";

      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'';
    };
  };

  home-manager.users.alapshin =
    let
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
        keepassxc-autostart
        thunderbird-autostart
      ];

      home.file = {
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
        configFile = {
          "nvim".source = "${dotfiles}/nvim";

          "tigrc".source = "${dotfiles}/tigrc";
          "git/config".source = "${dotfiles}/gitconfig";
          "git/config-alar".source = "${dotfiles}/gitconfig-alar";
          "fontconfig" = { source = "${dotfiles}/fontconfig"; recursive = true; };
          "zsh/.zshrc".source = "${dotfiles}/zshrc";
        };
      };
    };
}
