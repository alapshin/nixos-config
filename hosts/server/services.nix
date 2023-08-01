{ config
  , pkgs
  , ...
}: 
let
  hostname = "alapshin.com";
in {
  sops = {
    secrets = {
      "porkbun/api_key" = {
        owner =  config.users.users.acme.name;
      };
      "porkbun/secret_key" = {
        owner =  config.users.users.acme.name;
      };
      "nextcloud/password" = {
        owner = config.users.users.nextcloud.name;
      };
    };
  };

  users.users = {
    # Make sops keys available to acme user
    acme.extraGroups = [
      config.users.groups.keys.name
    ];
    # Make acme certificates available to nginx user
    nginx.extraGroups = [
      config.users.groups.acme.name
    ];
    # Make sops keys available to nextcloud user
    nextcloud.extraGroups = [
      config.users.groups.keys.name
    ];
  };

  security = {
    acme = {
      acceptTerms = true;
      certs."${hostname}" = {
        extraDomainNames = [
          "*.${hostname}"
        ];
      };
      defaults = {
        email = "mail@${hostname}";
        dnsProvider = "porkbun";
        credentialsFile = pkgs.writeText "dns-credentials" ''
          PORKBUN_API_KEY_FILE=${config.sops.secrets."porkbun/api_key".path}
          PORKBUN_SECRET_API_KEY_FILE=${config.sops.secrets."porkbun/secret_key".path }
        '';
      };
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };

    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedBrotliSettings = true;
      virtualHosts.${config.services.nextcloud.hostName} = {
        forceSSL = true;
        useACMEHost = hostname;
      };
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud27;
      https = true;
      hostName = "nextcloud.${hostname}";

      caching.redis = true;
      configureRedis = true;
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."nextcloud/password".path;
      };
      database.createLocally = true;

      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit calendar contacts memories tasks;
        gpoddersync = pkgs.fetchNextcloudApp rec {
          url = "https://github.com/thrillfall/nextcloud-gpodder/releases/download/3.8.1/gpoddersync.tar.gz";
          sha256 = "sha256-Hi/fBSzO6sjHI4at03mtoiIrc/DtxpdzZb7vT06X4Ag=";
        };
      };
    };
  };
}
