{ config
, pkgs
, ...
}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "linux/root" = {
        neededForUsers = true;
      };
    };
  };
}
