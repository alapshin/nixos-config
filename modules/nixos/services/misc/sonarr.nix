{ lib
, pkgs
, config
, ...
}:
with lib;

let
  cfg = config.services.sonarr;
  boolToString = b: if b then "True" else "False";
  # List of databses used by an application
  databases = [
    cfg.postgres.mainDatabase
  ] ++ lib.lists.optional cfg.log.databaseEnabled cfg.postgres.logDatabase;
  # Command to alter single databsed ownership
  alterDbCmd = db: ''
    $PSQL -tAc 'ALTER DATABASE "${db}" OWNER TO "${cfg.user}";'
  '';
  # PostgreSQL post-start script that wiil be called from systemd service
  alterDbScript = lib.strings.concatMapStringsSep "\n" alterDbCmd databases;
in
{
  options = {
    services.sonarr = {
      enable = mkEnableOption "Sonarr";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/sonarr/.config/NzbDrone";
        description = "The directory where Sonarr stores its data files.";
      };

      user = mkOption {
        type = types.str;
        default = "sonarr";
        description = "User under which Sonarr runs.";
      };

      group = mkOption {
        type = types.str;
        default = "sonarr";
        description = "Group under which Sonarr runs.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for the Sonarr web interface.
        '';
      };

      instanceName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Instance name";
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = ''
          SONARR__AUTH__APIKEY=secret_api_key
        '';
        description = ''
          Environment file as defined in {manpage}`systemd.exec(5)`.
        '';
      };

      auth = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            method = mkOption {
              type = types.nullOr (types.enum [
                "None"
                "Basic"
                "Forms"
                "External"
              ]);
              default = null;
              example = "Basic";
              description = "Authentication method";
            };

            type = mkOption {
              type = types.nullOr (types.enum [
                "Enabled"
                "DisabledForLocalAddresses"
              ]);
              default = null;
              example = "Enabled";
              description = "Authentication type";
            };
          };
        });
        default = null;
      };

      log = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            level = mkOption {
              type = types.enum [
                "info"
                "debug"
                "trace"
              ];
              default = "info";
            };

            consoleLevel = mkOption {
              type = types.nullOr types.enum [
                "info"
                "debug"
                "trace"
              ];
              default = null;
            };

            analyticsEnabled = mkOption {
              type = types.bool;
              default = false;
              description = "Enable sending of anonymous usage and error information";
            };

            databaseEnabled = mkOption {
              type = types.bool;
              default = false;
              description = "Enable storage of logs in database";
            };
          };
        });
        default = null;
      };

      postgres = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            host = mkOption {
              type = types.str;
            };

            port = mkOption {
              type = types.port;
              default = config.services.postgresql.settings.port;
            };

            logDatabase = mkOption {
              type = types.str;
              default = "sonarr-log";
            };

            mainDatabase = mkOption {
              type = types.str;
              default = "sonarr-main";
            };
          };
        });
        default = null;
      };

      server = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            host = mkOption {
              type = types.str;
              default = "0.0.0.0";
              description = "The host Sonarr binds to.";
            };

            port = mkOption {
              type = types.port;
              default = 8989;
              description = "The TCP port Sonarr will listen on.";
            };
          };
        });
        default = null;
      };

      package = mkPackageOption pkgs "sonarr" { };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.sonarr = {
      description = "Sonarr";
      after = [ "network.target" ];
      requires = mkIf (cfg.postgres != null) [
        "postgresql.service"
      ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        SONARR__APP__INSTANCENAME = mkIf (cfg.instanceName != null) cfg.instanceName;
        SONARR__APP__LAUNCHBROWSER = "False";

        SONARR__AUTH__METHOD = mkIf (cfg.auth != null) cfg.auth.method;
        SONARR__AUTH__REQUIRED = mkIf (cfg.auth != null) cfg.auth.type;

        SONARR__LOG__LEVEL = mkIf (cfg.log != null) cfg.log.level;
        SONARR__LOG__CONSOLELEVEL = mkIf (cfg.log != null) cfg.log.level;
        SONARR__LOG__DBENABLED = mkIf (cfg.log != null) (boolToString cfg.log.analyticsEnabled);
        SONARR__LOG__ANALYTICSENABLED = mkIf (cfg.log != null) (boolToString cfg.log.analyticsEnabled);

        SONARR__SERVER__PORT = mkIf (cfg.server != null) (toString cfg.server.port);
        SONARR__SERVER__BINDADDRESS = mkIf (cfg.server != null) cfg.server.host;

        SONARR__POSTGRES__HOST = mkIf (cfg.postgres != null) "${cfg.postgres.host}";
        SONARR__POSTGRES__PORT = mkIf (cfg.postgres != null) (toString cfg.postgres.port);
        SONARR__POSTGRESS__MAINDB = mkIf (cfg.postgres != null) cfg.postgres.mainDatabase;
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/NzbDrone -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users.users = mkIf (cfg.user == "sonarr") {
      sonarr = {
        home = cfg.dataDir;
        group = cfg.group;
        uid = config.ids.uids.sonarr;
      };
    };

    users.groups = mkIf (cfg.group == "sonarr") {
      sonarr.gid = config.ids.gids.sonarr;
    };

    services.postgresql = mkIf (cfg.postgres != null) {
      ensureUsers = [
        {
          name = cfg.user;
        }
      ];
      ensureDatabases = [
        cfg.postgres.mainDatabase
      ] ++ lib.optional cfg.log.databaseEnabled cfg.postgres.logDatabase;
    };

    systemd.services.postgresql.postStart = mkIf (cfg.postgres != null) (lib.mkAfter alterDbScript);
  };
}
