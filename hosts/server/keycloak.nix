{ lib
, pkgs
, config
, domainName
, ...
}:
let
  keycloakHttpsPort = 8443;
  keycloakHostname = "keycloak.${domainName}";
in
{
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
          useACMEHost = domainName;
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
      sslCertificate = "${config.security.acme.certs.${domainName}.directory}/cert.pem";
      sslCertificateKey = "${config.security.acme.certs.${domainName}.directory}/key.pem";
    };
  };
}
