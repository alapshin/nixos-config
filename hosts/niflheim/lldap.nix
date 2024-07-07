{ lib
, pkgs
, config
, ...
}:
let
  name = "lldap";
  host = config.services.lldap.settings.http_host;
  port = config.services.lldap.settings.http_port;
  user = config.services.lldap.settings.ldap_user_dn;
  ldapPort = config.services.lldap.settings.ldap_port;
  domainParts = lib.strings.splitString "." config.domain.base;
  ldapBaseDn = lib.strings.concatMapStringsSep "," (s: "dc=${s}") domainParts;
in
{
  sops = {
    secrets = {
      "lldap/jwt_secret" = { };
      "lldap/user_password" = { };
    };
  };

  services = {
    lldap = {
      enable = true;
      settings = {
        http_host = "localhost";
        ldap_host = "localhost";
        ldap_base_dn = ldapBaseDn;
        ldap_user_email = "${user}@${config.domain.base}";
        database_url = "postgres:///${name}";
      };
      environment = {
        LLDAP_JWT_SECRET_FILE = "%d/jwt_secret";
        LLDAP_LDAP_USER_PASS_FILE = "%d/user_password";
      };
    };

    postgresql = {
      ensureDatabases = [
        name
      ];
      ensureUsers = [
        {
          name = name;
          ensureDBOwnership = true;
        }
      ];
    };

    nginx-ext.applications."ldap" = {
      auth = true;
      inherit port;
    };
  };

  systemd.services.lldap = {
    requires = [
      "postgresql.service"
    ];
    serviceConfig = {
      LoadCredential = [
        "jwt_secret:${config.sops.secrets."lldap/jwt_secret".path}"
        "user_password:${config.sops.secrets."lldap/user_password".path}"
      ];
    };
  };
}
