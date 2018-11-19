# Settings that don't fit into particular category

{ config, pkgs, ... }:

{
  services = {
    locate = {
      enable = true;
      locate = pkgs.mlocate;
      # To silence warning message
      # See https://github.com/NixOS/nixpkgs/issues/30864
      localuser = null;
    };
    # Enable CUPS
    printing = {
      enable = true;
      drivers = [
        pkgs.hplip
      ];
    };
    redshift = {
      enable = true;
      provider = "manual";
      latitude = "58.5969";
      longitude = "49.6583";
      extraOptions = [ "-P" "-m randr" ];
    };
    # Enable Syncthing daemon
    syncthing = {
      enable = true;
      group = "syncthing";
    };
  };

  environment.systemPackages = with pkgs; [
    atool
    borgbackup
    chromium
    file
    firefox
    gimp
    gnupg
    htop
    inkscape
    libreoffice-fresh
    keepassxc
    manpages
    mpv
    neovim
    ntfs3g
    smplayer
    unzip
    wget 
    youtube-dl
  ];
}
