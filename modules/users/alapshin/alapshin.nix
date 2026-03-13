{ inputs, ... }:
{
  flake.modules.nixos.alapshin =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      users.users.alapshin = {
        uid = 1000;
        shell = pkgs.fish;
        isNormalUser = true;
        description = "Andrei Lapshin";
        extraGroups = [
          "adbusers"
          "audio"
          "docker"
          "input"
          "jackaudio"
          "libvirtd"
          "networkmanager"
          "syncthing"
          "tss"
          "wheel"
        ];

        packages =
          with pkgs;
          [
            audacity
            calibre
            gimp
            inkscape
            kid3-qt
            libreoffice-qt-fresh
            qbittorrent
            smplayer
            tor-browser
          ]
          ++ [
            pkgs.feather
            pkgs.electrum
          ]
          ++ [
            pkgs.aspell
            pkgs.aspellDicts.en
            pkgs.aspellDicts.es
            pkgs.aspellDicts.ru
            pkgs.aspellDicts.sr
            pkgs.hunspell
            pkgs.hunspellDicts.en-us
            pkgs.hunspellDicts.es-es
            pkgs.hunspellDicts.ru-ru
            pkgs.customHunspellDicts.sr
          ]
          ++ (with pkgs.kdePackages; [
            ark
            dolphin
            filelight
            gwenview
            kate
            kcolorchooser
            kleopatra
            spectacle
          ]);
      };

      home-manager.users.alapshin = {
        imports = [ inputs.self.modules.homeManager.alapshin ];
      };
    };

  # Home-manager user configuration (used by both NixOS module and standalone)
  flake.modules.homeManager.alapshin =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        base
        secrets
        shell
        neovim
        git
        gnupg
        firefox
        theming
        ai
        anki
        chromium
        development
        gaming
        plasma
        podman
        programs
        services
        ssh-client
        syncthing
        thunderbird
        variables
      ];

      sops.defaultSopsFile = ./secrets/secrets.yaml;

      secrets = {
        path = ./secrets/build/secrets.json;
      };

      home = {
        username = if pkgs.stdenv.hostPlatform.isLinux then "alapshin" else "andrei.lapshin";
        homeDirectory =
          if pkgs.stdenv.hostPlatform.isLinux then "/home/alapshin" else "/Users/andrei.lapshin";
      };
    };
}
