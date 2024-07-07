{ lib
, pkgs
, config
, ...
}: {
  sops = {
    secrets = {
      "porkbun/api_key" = {
        owner = config.users.users.acme.name;
      };
      "porkbun/secret_key" = {
        owner = config.users.users.acme.name;
      };
    };
  };

  users.users = {
    # Make sops keys available to acme user
    acme.extraGroups = [
      config.users.groups.keys.name
    ];
  };

  security = {
    acme = {
      acceptTerms = true;
      certs."${config.domain.base}" = {
        extraDomainNames = [
          "*.${config.domain.base}"
        ];
      };
      defaults = {
        email = "mail@${config.domain.base}";
        dnsProvider = "porkbun";
        credentialFiles = {
          "PORKBUN_API_KEY_FILE" = config.sops.secrets."porkbun/api_key".path;
          "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets."porkbun/secret_key".path;
        };
      };
    };
  };
}
