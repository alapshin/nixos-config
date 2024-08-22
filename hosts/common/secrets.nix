{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops = {
    age.sshKeyPaths = lib.mkDefault [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    defaultSopsFile = lib.mkDefault ./secrets.yaml;
  };
}
