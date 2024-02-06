
{ lib
, pkgs
, config
, ...
}: let 
  fqdn = config.networking.fqdnOrHostName;
  keycloakHttpsPort = 8443;
  keycloakHostname = "keycloak.${fqdn}";
in {
  sops = {
    secrets = {
      "keycloak/database" = {
        owner = config.users.users.postgres.name;
      };
    };
  };

  services = {
    nginx = {
      virtualHosts = {
        ${keycloakHostname} = {
          forceSSL = true;
          useACMEHost = fqdn;
          locations."/" = {
            proxyPass = "https://localhost:${toString keycloakHttpsPort}";
          };
        };
      };
    };
    keycloak = {
      enable = false;
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
      sslCertificate = "${config.security.acme.certs.${fqdn}.directory}/cert.pem";
      sslCertificateKey = "${config.security.acme.certs.${fqdn}.directory}/key.pem";
    };
  };
}
