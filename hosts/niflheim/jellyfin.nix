{
  lib,
  pkgs,
  config,
  ...
}:
let
  port = 8096;
in
{
  sops = {
    secrets = {
      "jellyfin/api_key" = { };
      "jellyseerr/api_key" = { };
    };
  };
  services = {
    jellyfin.enable = true;
    jellyseerr.enable = true;

    webhost.applications = {
      "jellyfin" = {
        auth = false;
        inherit port;
      };
      "jellyseerr" = {
        auth = true;
        port = config.services.jellyseerr.port;
      };
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "jellyfin";
              client_name = "Jellyfin";
              client_secret = "$pbkdf2-sha512$310000$w8/7AXV6ljEACFLwkc.neQ$bMnyFnhUjuFjhKGw.awXKfK1EK6n9XS5P6RcywAbBxLhI6hcJqJ8jDCt3oOBp9YpaPCbNh3Sm23NCwJaUIci5w";
              require_pkce = true;
              pkce_challenge_method = "S256";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://jellyfin.${config.services.webhost.basedomain}/sso/OID/redirect/authelia"
              ];
              token_endpoint_auth_method = "client_secret_post";
            }
          ];
        };
      };
    };

  };
}
