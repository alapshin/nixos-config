# Home-manager base configuration (locale, fonts, XDG, etc.)
{ ... }:
{
  flake.modules.homeManager.base =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      # Programs
      programs.nh.enable = true;
      programs.home-manager.enable = true;

      home.stateVersion = "24.11";

      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };

      # Home directory metadata
      home.language = {
        base = "en_US.UTF-8";
        time = "en_DK.UTF-8";
        paper = "en_DK.UTF-8";
        numeric = "en_DK.UTF-8";
        monetary = "en_IE.UTF-8";
        measurement = "en_DK.UTF-8";
      };
      home.sessionVariables.LC_ALL = "en_US.UTF-8";

      # Fonts
      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          emoji = [ "Noto Emoji" ];
          monospace = [ "JetBrainsMono Nerd Font Mono" ];
        };
      };

      # X session (Linux only)
      xsession.enable = pkgs.stdenv.hostPlatform.isLinux;

      # macOS specific
      targets.darwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        copyApps = {
          enable = true;
          enableChecks = false;
        };
        linkApps.enable = false;
      };

      # XDG base directories
      xdg = {
        enable = true;
        autostart = {
          enable = true;
          readOnly = true;
        };
        dataFile = {
          "konsole" = {
            source = "${config.dotfileDir}/konsole";
            recursive = true;
          };
        };
        configFile = {
          "fontconfig" = {
            source = "${config.dotfileDir}/fontconfig";
            recursive = true;
          };
          "glow/glow.yml".source = "${config.dotfileDir}/glow/glow.yml";
          "ideavim/ideavimrc".source = "${config.dotfileDir}/ideavimrc";
          "latexmk/latexmkrc".source = "${config.dotfileDir}/latexmkrc";
          "borgmatic/config.yaml".source = "${config.dotfileDir}/borgmatic.yaml";
        }
        // lib.attrsets.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
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

      # macOS sops workaround
      launchd.agents.sops-nix = pkgs.lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        config = {
          EnvironmentVariables = {
            PATH = pkgs.lib.mkForce "/usr/bin:/bin:/usr/sbin:/sbin";
          };
        };
      };
    };
}
