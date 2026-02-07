{
  lib,
  inputs,
  config,
  ...
}:
let
  domain = "netbird.${config.services.webhost.basedomain}";
in
{

  sops = {
    secrets = {
      "netbird/relay_secret" = {
      };
      "netbird/management_key" = {
      };
      "netbird/oidc_client_secret" = {
      };
    };
  };

  services = {
    netbird = {
      clients.wt0 = {
        port = 51822;
      };
      server = {
        enable = true;
        domain = domain;
        dashboard = {
          settings = {
            USE_AUTH0 = "false";
            AUTH_AUDIENCE = "netbird";
            AUTH_CLIENT_ID = "netbird";
            AUTH_AUTHORITY = "https://${config.services.webhost.authdomain}/";
            AUTH_REDIRECT_URI = "/auth";
            AUTH_SILENT_REDIRECT_URI = "/silent-auth";
            AUTH_SUPPORTED_SCOPES = "openid offline_access profile email groups";
            AUTH_USER_ID_CLAIM = "preferred_username";
            NETBIRD_TOKEN_SOURCE = "idToken";
          };
        };
        # relay = {
        #   enable = false;
        #   authSecretFile = config.sops.secrets."netbird/relay_secret".path;
        #   settings = {
        #     NB_STUN_PORTS = "3478";
        #     NB_ENABLE_STUN = "true";
        #     NB_EXPOSED_ADDRESS = "rels://${domain}:443/";
        #   };
        # };
        coturn = {
          enable = false;
        };
        signal = {
          enable = false;
          port = 8012;
          metricsPort = 9091;
        };
        management = {
          metricsPort = 19090;
          turnDomain = domain;
          oidcConfigEndpoint = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";
          disableAnonymousMetrics = true;
          settings = {
            Signal.URI = "${domain}:443";
            DataStoreEncryptionKey._secret = config.sops.secrets."netbird/management_key".path;
            HttpConfig = {
              CertKey = "";
              CertFile = "";
              AuthAudience = "netbird";
              AuthIssuer = "https://${config.services.webhost.authdomain}";
              AuthKeysLocation = "https://${config.services.webhost.authdomain}/jwks.json";
              IdpSignKeyRefreshEnabled = true;
            };
            PKCEAuthorizationFlow = {
              ProviderConfig = {
                Domain = "";
                ClientID = "netbird";
                ClientSecret._secret = config.sops.secrets."netbird/oidc_client_secret".path;
                Audience = "netbird";
                TokenEndpoint = "https://${config.services.webhost.authdomain}/api/oidc/token";
                DeviceAuthEndpoint = "";
                AuthorizationEndpoint = "https://${config.services.webhost.authdomain}/api/oidc/authorization";
                Scope = "openid profile email groups";
                UseIDToken = true;
                RedirectURLs = [ "http://localhost:53000" ];
              };
            };
            DeviceAuthorizationFlow = {
              Provider = "hosted";
              ProviderConfig = {
                Audience = "netbird";
                AuthorizationEndpoint = "";
                ClientID = "netbird";
                ClientSecret._secret = config.sops.secrets."netbird/oidc_client_secret".path;
                TokenEndpoint = "https://${config.services.webhost.authdomain}/api/oidc/token";
                Domain = config.services.webhost.authdomain;
                DeviceAuthEndpoint = "https://${config.services.webhost.authdomain}/api/oidc/device-authorization";
                LoginFlag = 0;
                RedirectURLs = null;
                DisablePromptLogin = false;
                Scope = "openid profile email groups offline_access";
                UseIDToken = true;
              };
            };
            Stuns = [
              {
                Proto = "udp";
                URI = "stun:${domain}:3478";
                Username = "";
                Password = "";
              }
            ];
            TURNConfig = {
              Secret._secret = config.sops.secrets."netbird/relay_secret".path;
              TimeBasedCredentials = false;
              CredentialsTTL = "24h0m0s";
              Turns = [
                {
                  Proto = "udp";
                  URI = "turn:${domain}:3478";
                  Username = "netbird";
                  Password._secret = config.sops.secrets."netbird/relay_secret".path;
                }
              ];
            };
          };
        };
      };
    };

    caddy.virtualHosts."${domain}" = rec {
      hostName = domain;
      extraConfig = ''
        # Management API - HTTP REST endpoints
        handle /api* {
          reverse_proxy localhost:${toString config.services.netbird.server.management.port}
        }

        # Management Service - gRPC endpoints
        handle /management.ManagementService/* {
          reverse_proxy localhost:${toString config.services.netbird.server.management.port} {
            transport http {
              versions h2c 2
            }
            # gRPC requires special headers
            header_up X-Forwarded-For {remote_host}
          }
        }

        # Signal Exchange - gRPC endpoints
        handle /signalexchange.SignalExchange/* {
          reverse_proxy localhost:${toString config.services.netbird.server.signal.port} {
            transport http {
              versions h2c 2
            }
            header_up X-Forwarded-For {remote_host}
          }
        }

        # Dashboard - Static files
        handle {
          root ${config.services.netbird.server.dashboard.finalDrv}
          file_server
          try_files {path} {path}.html {path}/ /404.html
        }
      '';
    };

    authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        public = true;
        client_id = "netbird";
        client_name = "Netbird";
        audience = "netbird";
        authorization_policy = "one_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "http://localhost:53000"
          "https://${domain}"
          "https://${domain}/auth"
          "https://${domain}/silent-auth"
        ];
        scopes = [
          "openid"
          "email"
          "profile"
          "offline_access"
          "groups"
        ];
        grant_types = [
          "authorization_code"
          "urn:ietf:params:oauth:grant-type:device_code"
        ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 3478 ];
}
