{
  pkgs,
  lib,
  inputs,
  isNixOS,
  username,
  dotfileDir,
  ...
}:
{

  home = {
    username = username;
    stateVersion = "24.11";
    homeDirectory = "/home/${username}";
  };

  imports =
    [
      ./development.nix
      ./gaming.nix
      ./git.nix
      ./gnupg.nix
      ./programs.nix
      ./ssh.nix
      ./shell.nix
      # ./plasma.nix
      ./neovim.nix
      ./texlive.nix
      ./timetracking.nix

      ./theming.nix
      ./packages.nix
      ./variables.nix
    ]
    ++ (lib.lists.optionals isNixOS [
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

  xsession.enable = true;
  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
    autostart = {
      enable = true;
      entries = [
        "${pkgs.keepassxc}/share/applications/org.keepassxc.KeePassXC.desktop"
        "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
      ];
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

      # https://github.com/nix-community/home-manager/issues/1213#issuecomment-626240819
      "mimeapps.list".force = true;

      "glow/glow.yml".source = "${dotfileDir}/glow/glow.yml";
      "ideavim/ideavimrc".source = "${dotfileDir}/ideavimrc";
      "latexmk/latexmkrc".source = "${dotfileDir}/latexmkrc";
      "borgmatic/config.yaml".source = "${dotfileDir}/borgmatic.yaml";
    };
    mimeApps = {
      enable = true;
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

  home.activation.diff = inputs.home-manager.lib.hm.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';
}
