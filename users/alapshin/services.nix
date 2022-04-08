{ config, myutils, pkgs, ... }:

let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  services = {
    syncthing = {
      enable = true;
      user = username;
      group = "users";
      dataDir = "/home/${username}";
      folders = {
        "/home/${username}/Syncthing" = {
          id = "syncthing";
          label = "Syncthing";
        };
      };
      overrideFolders = true;
      overrideDevices = false;
    };
    locate = {
      enable = true;
      locate = pkgs.mlocate;
      # To silence warning message
      # See https://github.com/NixOS/nixpkgs/issues/30864
      localuser = null;
    };
  };
}
