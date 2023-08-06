{ config
, pkgs
, ...
}: {
  sops = {
    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };
    secrets = {
      "borg/passphrase" = {
        sopsFile = ./secrets/borg/passphrase.yaml;
      };
      "borg/keyfile" = {
        format = "binary";
        sopsFile = ./secrets/borg/keyfile;
      };
      "borg/borg_ed25519" = {
        format = "binary";
        sopsFile = ./secrets/borg/borg_ed25519;
      };
      "borg/borg_ed25519.pub" = {
        format = "binary";
        sopsFile = ./secrets/borg/borg_ed25519.pub;
      };
      "wireguard/public_key" = {
        format = "binary";
        sopsFile = ./secrets/wireguard/public_key;
      };
      "wireguard/private_key" = {
        format = "binary";
        sopsFile = ./secrets/wireguard/private_key;
      };
    };
  };
}
