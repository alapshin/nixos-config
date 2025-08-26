{
  lib,
  pkgs,
  username,
  dotfileDir,
  ...
}:
let
  hostname = osConfig.networking.hostName;
in
{

  imports = [
    ./anki.nix
    ./chromium.nix
    ./development.nix
    ./firefox.nix
    ./gaming.nix
    ./git.nix
    ./gnupg.nix
    ./neovim.nix
    ./plasma.nix
    ./programs.nix
    ./ssh.nix
    ./services.nix
    ./shell.nix
    ./syncthing.nix
    ./texlive.nix
    ./thunderbird.nix

    ./theming.nix
    ./packages.nix
    ./variables.nix
  ];

  secrets = {
    path = ../secrets/build/secrets.json;
  };

  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      "openrouter_api_key" = {
        path = "%r/openrouter_api_key";
      };
    };
  };

  programs.nh.enable = true;
  programs.home-manager.enable = true;

  home = {
    inherit username;
    stateVersion = "24.11";
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isLinux then "/home/${username}" else "/Users/${username}";
  };

  home.language = {
    base = "en_US.UTF-8";
    time = "en_DK.UTF-8";
    paper = "en_DK.UTF-8";
    numeric = "en_DK.UTF-8";
    monetary = "en_IE.UTF-8";
    measurement = "en_DK.UTF-8";
  };

  xsession.enable = pkgs.stdenv.hostPlatform.isLinux;
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      emoji = [ "Noto Emoji" ];
      monospace = [ "JetBrainsMono Nerd Font Mono" ];
    };
  };

  xdg = {
    enable = true;
    autostart = {
      enable = true;
    };
    dataFile = {
      "konsole" = {
        source = "${dotfileDir}/konsole";
        recursive = true;
      };
    };
    configFile = {
      "fontconfig" = {
        source = "${dotfileDir}/fontconfig";
        recursive = true;
      };

      "glow/glow.yml".source = "${dotfileDir}/glow/glow.yml";
      "ideavim/ideavimrc".source = "${dotfileDir}/ideavimrc";
      "latexmk/latexmkrc".source = "${dotfileDir}/latexmkrc";
      "borgmatic/config.yaml".source = "${dotfileDir}/borgmatic.yaml";
    }
    // lib.attrsets.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # https://github.com/nix-community/home-manager/issues/1213#issuecomment-626240819
      "mimeapps.list".force = true;
    };
    mimeApps = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "text/plain" = "org.kde.kwrite.desktop";

        "application/pdf" = "org.kde.okular.desktop";
        "application/vnd.oasis.opendocument.text" = "writer.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
        "application/vnd.oasis.opendocument.presentation" = "impress.desktop";

        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";
      };
    };
  };
}
