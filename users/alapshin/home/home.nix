{
  pkgs,
  lib,
  inputs,
  isLinux,
  isNixOS,
  username,
  dotfileDir,
  ...
}:
{

  home = {
    inherit username;
    stateVersion = "24.11";
    homeDirectory = if pkgs.stdenv.isLinux then "/home/${username}" else "/Users/${username}";
  };

  imports =
    [
      ./development.nix
      ./git.nix
      ./gnupg.nix
      ./programs.nix
      ./ssh.nix
      ./shell.nix
      ./neovim.nix

      ./theming.nix
      ./packages.nix
      ./variables.nix
    ]
    ++ (lib.lists.optionals isLinux [
      ./gaming.nix
    ])
    ++ (lib.lists.optionals isNixOS [
      ./plasma.nix
      ./texlive.nix
      ./chromium.nix
      ./firefox.nix
      ./thunderbird.nix
    ]);

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

  programs.home-manager.enable = true;

  home.language = {
    base = "en_US.UTF-8";
    time = "en_DK.UTF-8";
    paper = "en_DK.UTF-8";
    numeric = "en_DK.UTF-8";
    monetary = "en_IE.UTF-8";
    measurement = "en_DK.UTF-8";
  };

  xsession.enable = isLinux || isNixOS;
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
      entries = [
        "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
      ];
    };
    dataFile = {
      "konsole" = {
        source = "${dotfileDir}/konsole";
        recursive = true;
      };
    };
    configFile =
      {
        "fontconfig" = {
          source = "${dotfileDir}/fontconfig";
          recursive = true;
        };

        "glow/glow.yml".source = "${dotfileDir}/glow/glow.yml";
        "ideavim/ideavimrc".source = "${dotfileDir}/ideavimrc";
        "latexmk/latexmkrc".source = "${dotfileDir}/latexmkrc";
        "borgmatic/config.yaml".source = "${dotfileDir}/borgmatic.yaml";
      }
      // lib.attrsets.optionalAttrs (isLinux || isNixOS) {
        # https://github.com/nix-community/home-manager/issues/1213#issuecomment-626240819
        "mimeapps.list".force = true;
      };
    mimeApps = {
      enable = isLinux || isNixOS;
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
