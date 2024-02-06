{ lib
, pkgs
, config
, ...
}: 
{
  users.users = {
    # Make acme certificates available to nginx user
    nginx.extraGroups = [
      config.users.groups.acme.name
    ];
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };

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

    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedBrotliSettings = true;
      recommendedProxySettings = true;
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
    };
  };
}
