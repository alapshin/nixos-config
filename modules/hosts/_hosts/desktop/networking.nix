{
  lib,
  pkgs,
  config,
  ...
}:

{
  networking.hostName = "desktop";
  environment.systemPackages = with pkgs; [
    pritunl-client
  ];
}
