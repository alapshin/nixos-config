# User account configuration for alapshin
{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  username = "alapshin";
  homeDir = ../../users/alapshin;

  blockchainPackages = with pkgs; [
    feather
    electrum
  ];

  dictionaries = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.es
    aspellDicts.ru
    aspellDicts.sr
    hunspell
    hunspellDicts.en-us
    hunspellDicts.es-es
    hunspellDicts.ru-ru
    customHunspellDicts.sr
  ];
in
{
  users.users."${username}" = {
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
      ++ blockchainPackages
      ++ dictionaries
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

  # Home-manager integration for the user
  home-manager.users."${username}" =
    { ... }:
    {
      imports = [ (homeDir + "/home/home.nix") ];
      _module.args = {
        inherit username;
      };
    };
}
