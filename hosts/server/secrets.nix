{ config
, pkgs
, ...
}: {
  sops = {
    defaultSopsFile = ../../secrets/default.yaml;
    secrets = {
      rootpass = {
        format = "binary";
        neededForUsers = true;
        sopsFile = ./secrets/rootpass;
      };
    };
  };
}
