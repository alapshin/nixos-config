{
  lib,
  pkgs,
  config,
  ...
}:
let
  name = "lldap";
  port = 17170;
  user = "admin";
  email = "${user}@${config.services.webhost.basedomain}";
  domainParts = lib.strings.splitString "." config.services.webhost.basedomain;
  ldapBaseDn = lib.strings.concatMapStringsSep "," (s: "dc=${s}") domainParts;
in
{
  sops = {
    secrets = {
      "lldap/jwt_secret" = {
        owner = "lldap";
        group = "lldap";
      };
      "lldap/user_password" = {
        owner = "lldap";
        group = "lldap";
      };
    };
  };

  services = {
    lldap = {
      enable = true;
      settings = {
        http_port = port;
        http_host = "localhost";
        http_url = "https://ldap.${config.services.webhost.basedomain}";
        jwt_secret_file = config.sops.secrets."lldap/jwt_secret".path;
        ldap_host = "localhost";
        ldap_base_dn = ldapBaseDn;
        ldap_user_dn = user;
        ldap_user_email = email;
        ldap_user_pass_file = config.sops.secrets."lldap/user_password".path;
        force_ldap_user_pass_reset = "always";
        database_url = "postgres:///${name}";
      };
    };

    postgresql = {
      ensureDatabases = [ name ];
      ensureUsers = [
        {
          name = name;
          ensureDBOwnership = true;
        }
      ];
    };

    webhost.applications."ldap" = {
      auth = true;
      inherit port;
    };
  };

  systemd.services.lldap = {
    requires = [ "postgresql.service" ];
  };
}
