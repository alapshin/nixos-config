{ lib
, pkgs
, config
, ...
}: let 
  fqdn = config.networking.fqdnOrHostName;
in {
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
      certs."${fqdn}" = {
        extraDomainNames = [
          "*.${fqdn}"
        ];
      };
      defaults = {
        email = "mail@${fqdn}";
        dnsProvider = "porkbun";
        credentialsFile = pkgs.writeText "dns-credentials" ''
          PORKBUN_API_KEY_FILE=${config.sops.secrets."porkbun/api_key".path}
          PORKBUN_SECRET_API_KEY_FILE=${config.sops.secrets."porkbun/secret_key".path }
        '';
      };
    };
  };
}
