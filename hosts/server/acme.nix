{ lib
, pkgs
, config
, domainName
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
      certs."${domainName}" = {
        extraDomainNames = [
          "*.${domainName}"
        ];
      };
      defaults = {
        email = "mail@${domainName}";
        dnsProvider = "porkbun";
        credentialFiles = {
          "PORKBUN_API_KEY_FILE" = config.sops.secrets."porkbun/api_key".path;
          "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets."porkbun/secret_key".path;
        };
        dnsPropagationCheck = false;
      };
    };
  };
}
