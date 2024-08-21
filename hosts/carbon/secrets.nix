{ config, pkgs, ... }:
{
  sops = {
    secrets = {
      "wireguard/public_key" = {
        format = "binary";
        sopsFile = ./secrets/wireguard/public_key;
      };
      "wireguard/private_key" = {
        format = "binary";
        sopsFile = ./secrets/wireguard/private_key;
      };
    };

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
