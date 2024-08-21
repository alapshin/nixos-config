app:

{
  lib,
  pkgs,
  config,
  ...
}:
with lib;

let
  cfg = config.services."${app}";

  userName = app;
  groupName = app;
  appName = capitalize app;
  envVarPrefix = lib.strings.toUpper app;
  packageName = app;

  defaultPort =
    if app == "sonarr" then
      8989
    else if app == "radarr" then
      7878
    else if app == "lidarr" then
      8686
    else if app == "readarr" then
      8787
    else if app == "prowlarr" then
      9696
    else
      abort "App ${app} is not supported";

  defaultDataDir =
    if app == "sonarr" then
      "${app}/.config/NzbDrone"
    else if app == "radarr" then
      "${app}/.config/Radarr"
    else if app == "lidarr" then
      "lidarr"
    else if app == "readarr" then
      "readarr"
    else if app == "prowlarr" then
      "prowlarr"
    else
      abort "App ${app} is not supported";

  capitalize =
    str:
    lib.strings.toUpper (lib.strings.substring 0 1 str)
    + lib.strings.substring 1 (lib.strings.stringLength str) str;
  boolToSharpString = b: capitalize (boolToString b);

  # List of databses used by an application
  databases =
    [ cfg.postgres.mainDatabase ]
    ++ lib.lists.optional cfg.log.databaseEnabled cfg.postgres.logDatabase
    ++ lib.lists.optional (cfg.postgres ? "cacheDatabase") cfg.postgres.cacheDatabase;
  # Command to alter databse ownership
  alterDbCmd = db: ''
    $PSQL -tAc 'ALTER DATABASE "${db}" OWNER TO "${cfg.user}";'
  '';
  # PostgreSQL systemd service post-start script
  alterDbScript = lib.strings.concatMapStringsSep "\n" alterDbCmd databases;
in
{
  options = {
    services."${app}" = {
      enable = mkEnableOption "${appName}";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/${defaultDataDir}";
        description = "The directory where ${appName} stores its data files.";
      };

      user = mkOption {
        type = types.str;
        default = userName;
        description = "User under which ${appName} runs.";
      };

      group = mkOption {
        type = types.str;
        default = groupName;
        description = "Group under which ${appName} runs.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for the ${appName} web interface.
        '';
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = ''
          ${envVarPrefix}__AUTH__APIKEY=secret_api_key
        '';
        description = ''
          Environment file as defined in {manpage}`systemd.exec(5)`.
        '';
      };

      app = mkOption {
        type = types.nullOr (
          types.submodule {
            instance = mkOption {
              type = types.str;
              default = appName;
              description = "Instance name";
            };
          }
        );
        default = null;
        description = "App options";
      };

      auth = mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              method = mkOption {
                type = types.nullOr (
                  types.enum [
                    "None"
                    "Basic"
                    "Forms"
                    "External"
                  ]
                );
                default = "None";
                example = "External";
                description = "Authentication method for access to the Web UI";
              };

              type = mkOption {
                type = types.nullOr (
                  types.enum [
                    "Enabled"
                    "DisabledForLocalAddresses"
                  ]
                );
                default = "Enabled";
                example = "DisabledForLocalAddresses";
                description = "Which addresses authentication is applied to";
              };
            };
          }
        );
        default = null;
        description = "Authentication options";
      };

      log = mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              level = mkOption {
                type = types.enum [
                  "info"
                  "debug"
                  "trace"
                ];
                default = "info";
                example = "debug";
                description = "Log level";
              };

              consoleLevel = mkOption {
                type = types.nullOr types.enum [
                  "info"
                  "debug"
                  "trace"
                ];
                default = null;
                example = "info";
                description = "Console log level";
              };

              databaseEnabled = mkOption {
                type = types.bool;
                default = true;
                description = "Enable database log storage.";
              };

              analyticsEnabled = mkOption {
                type = types.bool;
                default = false;
                description = "Enable sending of anonymous usage and error information";
              };

            };
          }
        );
        default = null;
        description = "Logging options";
      };

      postgres = mkOption {
        type = types.nullOr (
          types.submodule {
            options =
              {
                host = mkOption { type = types.str; };

                port = mkOption {
                  type = types.port;
                  default = config.services.postgresql.settings.port;
                };

                logDatabase = mkOption {
                  type = types.str;
                  default = "${app}-log";
                  description = "Log databse name used to store logs";
                };

                mainDatabase = mkOption {
                  type = types.str;
                  default = "${app}-main";
                  description = "Main databse name used to store configuration and history";
                };
              }
              // lib.optionalAttrs (app == "readarr") {
                cacheDatabase = mkOption {
                  type = types.str;
                  default = "${app}-cache";
                  description = "Cache databse name used to store GoodReads cache";
                };
              };
          }
        );
        default = null;
        description = "PostgreSQL connection options";
      };

      server = mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              host = mkOption {
                type = types.str;
                default = "0.0.0.0";
                example = "127.0.0.1";
                description = "The host ${appName} binds to.";
              };

              port = mkOption {
                type = types.port;
                default = defaultPort;
                example = 9999;
                description = "The TCP port ${appName} will listen on.";
              };
            };
          }
        );
        default = null;
        description = "Server options";
      };

      package = mkPackageOption pkgs packageName { };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "10-${app}" = {
        "${cfg.dataDir}" = {
          d = {
            mode = "0700";
            user = cfg.user;
            group = cfg.group;
          };
        };
      };
    };

    systemd.services."${app}" = {
      description = appName;
      after = [ "network.target" ];
      requires = mkIf (cfg.postgres != null) [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        "${envVarPrefix}__APP__INSTANCENAME" = mkIf (cfg.app != null) cfg.app.instance;
        "${envVarPrefix}__APP__LAUNCHBROWSER" = "False";

        "${envVarPrefix}__AUTH__METHOD" = mkIf (cfg.auth != null) cfg.auth.method;
        "${envVarPrefix}__AUTH__REQUIRED" = mkIf (cfg.auth != null) cfg.auth.type;

        "${envVarPrefix}__LOG__LEVEL" = mkIf (cfg.log != null) cfg.log.level;
        "${envVarPrefix}__LOG__CONSOLELEVEL" = mkIf (cfg.log != null) cfg.log.level;
        "${envVarPrefix}__LOG__DBENABLED" = mkIf (cfg.log != null) (
          boolToSharpString cfg.log.analyticsEnabled
        );
        "${envVarPrefix}__LOG__ANALYTICSENABLED" = mkIf (cfg.log != null) (
          boolToSharpString cfg.log.analyticsEnabled
        );

        "${envVarPrefix}__SERVER__PORT" = mkIf (cfg.server != null) (toString cfg.server.port);
        "${envVarPrefix}__SERVER__BINDADDRESS" = mkIf (cfg.server != null) cfg.server.host;

        "${envVarPrefix}__POSTGRES__HOST" = mkIf (cfg.postgres != null) "${cfg.postgres.host}";
        "${envVarPrefix}__POSTGRES__PORT" = mkIf (cfg.postgres != null) (toString cfg.postgres.port);
        "${envVarPrefix}__POSTGRESS__MAINDB" = mkIf (cfg.postgres != null) cfg.postgres.mainDatabase;
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${lib.getExe cfg.package} -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
        StateDirectory = mkIf (cfg.dataDir == "/var/lib/${app}") app;
        StateDirectoryMode = "0700";
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };
    };

    networking.firewall = mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    users.users = mkIf (cfg.user == userName) {
      "${userName}" = {
        home = cfg.dataDir;
        group = cfg.group;
        # Needed for prowlarr because it doesn't have predefined uid
        uid = config.ids.uids."${userName}" or null;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == groupName) {
      "${groupName}" = {
        # Needed for prowlarr because it doesn't have predefined gid
        gid = config.ids.gids."${groupName}" or null;
      };
    };

    services.postgresql = mkIf (cfg.postgres != null) {
      ensureUsers = [ { name = cfg.user; } ];
      ensureDatabases = databases;
    };

    systemd.services.postgresql.postStart = mkIf (cfg.postgres != null) (lib.mkAfter alterDbScript);
  };
}
