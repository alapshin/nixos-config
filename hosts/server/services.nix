{ config
  , pkgs
  , ...
}: 
let
  hostname = "alapshin.com";
  keycloakHttpsPort = 8443;
  keycloakHostname = "keycloak.${hostname}";
  nextcloudHostname = "nextcloud.${hostname}";
in {
  sops = {
    secrets = {
      "keycloak/database" = {
        owner = config.users.users.postgres.name;
      };
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
      virtualHosts = {
        ${nextcloudHostname} = {
          forceSSL = true;
          useACMEHost = hostname;
        };
        ${keycloakHostname} = {
          forceSSL = true;
          useACMEHost = hostname;
          locations."/" = {
            proxyPass = "https://localhost:${toString keycloakHttpsPort}";
          };
        };
      };
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
    };

    keycloak = {
      enable = true;
      settings = {
        hostname = keycloakHostname;
        proxy = "passthrough";
        http-host = "localhost";
        https-port = keycloakHttpsPort;
      };
      database = {
        createLocally = true;
        passwordFile = config.sops.secrets."keycloak/database".path;
      };
      initialAdminPassword = "dfdsadsdsAAA";
      sslCertificate = "${config.security.acme.certs.${hostname}.directory}/cert.pem";
      sslCertificateKey = "${config.security.acme.certs.${hostname}.directory}/key.pem";
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud27;
      https = true;
      hostName = nextcloudHostname;

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
