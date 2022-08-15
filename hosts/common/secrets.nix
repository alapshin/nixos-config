{
  config,
  pkgs,
  ...
}: {
  sops = {
    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };
    defaultSopsFile = ../../secrets/default.yaml;
    secrets = {
      "borg/encryption_passphrase" = {
        sopsFile = ../../secrets/borg/passphrase.yaml;
      };
      "borg/borgbase_ed25519" = {
        format = "binary";
        sopsFile = ../../secrets/borg/borgbase_ed25519;
      };
      "borg/borgbase_ed25519.pub" = {
        format = "binary";
        sopsFile = ../../secrets/borg/borgbase_ed25519.pub;
      };
      "borg/keys/rm4i22x5_repo_borgbase_com__repo" = {
        format = "binary";
        sopsFile = ../../secrets/borg/keys/rm4i22x5_repo_borgbase_com__repo;
      };
    };
  };
}
