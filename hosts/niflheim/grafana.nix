{
  lib,
  pkgs,
  config,
  ...
}:
let
  dbUser = "grafana";
  dbName = config.services.grafana.settings.database.name;
  prometheusPort = config.services.prometheus.port;
  nodeExporterDashboard = pkgs.fetchgit {
    url = "https://github.com/rfmoz/grafana-dashboards.git";
    rev = "cad8539cc4c4ed043935e69b9c1ec23e551806f4";
    nonConeMode = true;
    sparseCheckout = [ "/prometheus/node-exporter-full.json" ];
    sha256 = "sha256-KtUmo5+p49lEWl8C8IFIT3volMYm99SV5CEyRcPsy3U=";
  };
in
{
  sops = {
    secrets = {
      "grafana/secret_key" = {
        owner = "grafana";
      };
      "grafana/admin_username" = {
        owner = "grafana";
      };
      "grafana/admin_password" = {
        owner = "grafana";
      };
      "grafana/oidc_client_secret" = {
        owner = "grafana";
      };
    };
  };

  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          root_url = "https://grafana.${config.services.webhost.basedomain}";
        };
        database = {
          type = "postgres";
          user = dbUser;
          host = "/run/postgresql/";
        };
        security = {
          secret_key = "$__file{${config.sops.secrets."grafana/secret_key".path}}";
          admin_user = "$__file{${config.sops.secrets."grafana/admin_username".path}}";
          admin_email = "superadmin@localhost";
          admin_password = "$__file{${config.sops.secrets."grafana/admin_password".path}}";
        };

        "auth" = {
          disable_login_form = true;
        };

        "auth.generic_oauth" = {
          enabled = true;
          name = "Authelia";
          client_id = "grafana";
          client_secret = "$__file{${config.sops.secrets."grafana/oidc_client_secret".path}}";
          api_url = "https://${config.services.webhost.authdomain}/api/oidc/userinfo";
          auth_url = "https://${config.services.webhost.authdomain}/api/oidc/authorization";
          token_url = "https://${config.services.webhost.authdomain}/api/oidc/token";

          use_pkce = true;
          empty_scopes = false;
          scopes = "openid profile email groups";
          role_attribute_strict = true;
          allow_assign_grafana_admin = true;
          name_attribute_path = "name";
          groups_attribute_path = "groups";
          login_attribute_path = "preferred_username";
          role_attribute_path = "contains(groups, 'grafana-admins') && 'GrafanaAdmin' || contains(groups, 'grafana-editors') && 'Editor' || 'Viewer'";
        };
      };

      provision.dashboards.settings.providers = [
        {
          # https://grafana.com/docs/grafana/latest/datasources/prometheus/
          name = "Node Exporter Dashboard";
          type = "file";
          options.path = "${nodeExporterDashboard}/prometheus";
        }
      ];

      provision.datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:${toString prometheusPort}";
        }
      ];
    };

    postgresql = {
      ensureDatabases = [ dbName ];
      ensureUsers = [
        {
          name = dbUser;
          ensureDBOwnership = true;
        }
      ];
    };

    webhost.applications."grafana" = {
      auth = true;
      port = config.services.grafana.settings.server.http_port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "grafana";
              client_name = "Grafana";
              client_secret = "$pbkdf2-sha512$310000$c6S3Q5j25GIJu2VBLf5VFg$S.j/GnNOjD40jpaSlizdi8gQnY2YXJusJcSOcIg8QgV8IkwAC9ILW1U21FrGMqePzfwoXYoYvgG.ZWk01MTo2Q";
              require_pkce = true;
              pkce_challenge_method = "S256";
              authorization_policy = "one_factor";
              redirect_uris = [ "https://grafana.${config.services.webhost.basedomain}/login/generic_oauth" ];
            }
          ];
        };
      };
    };
  };

  systemd.services."grafana" = {
    requires = [ "postgresql.service" ];
  };
}
