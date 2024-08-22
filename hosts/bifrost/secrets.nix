{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "linux/root" = {
        neededForUsers = true;
      };
    };
  };
}
