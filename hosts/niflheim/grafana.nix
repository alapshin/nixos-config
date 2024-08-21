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
          root_url = "https://grafana.${config.domain.base}";
        };
        database = {
          type = "postgres";
          user = dbUser;
          host = "/run/postgresql/";
        };
        security = {
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
          api_url = "https://${config.domain.auth}/api/oidc/userinfo";
          auth_url = "https://${config.domain.auth}/api/oidc/authorization";
          token_url = "https://${config.domain.auth}/api/oidc/token";

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

    nginx-ext.applications."grafana" = {
      auth = true;
      port = config.services.grafana.settings.server.http_port;
    };
  };

  systemd.services."grafana" = {
    requires = [ "postgresql.service" ];
  };
}
