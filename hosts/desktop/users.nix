{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops = {
    secrets = {
      "users/root" = {
        sopsFile = ./secrets/passwd.yaml;
        neededForUsers = true;
      };
      "users/alapshin" = {
        sopsFile = ./secrets/passwd.yaml;
        neededForUsers = true;
      };
    };
  };

  users.users = {
    root.hashedPasswordFile = config.sops.secrets."users/root".path;
    alapshin = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."users/alapshin".path;
    };
  };
}
