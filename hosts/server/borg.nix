{ lib
, pkgs
, config
, ...
}:
{
  services = {
    borgbackup = {
      repos = {
        "carbon" = {
          path = "/var/lib/borgbackup/carbon";
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsBOvXebWJDBkdv0oPjwjtB6Icn5kxCv7WN93Qg8VWD"
          ];
        };
      };
    };
  };
}
