{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops = {
    age.sshKeyPaths = lib.mkForce [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    gnupg.sshKeyPaths = [ ];
    defaultSopsFile = lib.mkDefault ./secrets.yaml;
  };
}
