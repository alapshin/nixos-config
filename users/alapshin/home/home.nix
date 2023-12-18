{ pkgs
, username
, dotfileDir
, ...
}: {
  home.stateVersion = "23.11";

  home.username = username;
  home.homeDirectory = "/home/${username}";

  imports = [
    ./git.nix
    ./gnupg.nix
    ./shell.nix
    # ./plasma.nix
    ./neovim.nix
    ./firefox.nix
    ./thunderbird.nix

    ./packages.nix
    ./variables.nix
  ];

  home.packages = with pkgs; [
    keepassxc-autostart
    telegram-autostart
    thunderbird-autostart
  ];

  home.file = {
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

  home.pointerCursor = {
    name = "breeze_cursors";
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.breeze-qt5;
  };

  xsession.enable = true;
  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
    dataFile = {
      "konsole" = {
        source = "${dotfileDir}/konsole";
        recursive = true;
      };
    };
    configFile = {
      "nvim" = {
        source = "${dotfileDir}/nvim";
        recursive = true;
      };
      "fontconfig" = {
        source = "${dotfileDir}/fontconfig";
        recursive = true;
      };

      "zsh/p10k.zsh".source = "${dotfileDir}/p10k.zsh";
      "glow/glow.yml".source = "${dotfileDir}/glow/glow.yml";
      "ideavim/ideavimrc".source = "${dotfileDir}/ideavimrc";
      "latexmk/latexmkrc".source = "${dotfileDir}/latexmkrc";
      "borgmatic/config.yaml".source = "${dotfileDir}/borgmatic.yaml";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.kde.okular.desktop";
        "text/html" = "firefox.desktop";
        "text/plain" = "org.kde.kwrite.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";
      };
    };
  };
}
