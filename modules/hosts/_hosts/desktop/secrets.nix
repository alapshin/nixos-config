{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
  };
}
