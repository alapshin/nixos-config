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
  };
}
