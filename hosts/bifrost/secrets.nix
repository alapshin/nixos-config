{ config, pkgs, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "linux/root" = {
        neededForUsers = true;
      };
    };
    # Import host SSH keys as age kys
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # Don't import host SSH RSA keys as gpg keys
    gnupg.sshKeyPaths = [ ];
  };
}
