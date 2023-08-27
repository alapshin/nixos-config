{ config
, lib
, pkgs
, ...
}:
let
  pkg = pkgs.qbittorrent-nox;
  cfg = config.services.qbittorrent;

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in
{
  options.services.qbittorrent = {
    enable = mkEnableOption "qbittorrent";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = ''
        The directory where qBittorrent will create files.
      '';
    };

    configDir = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/.config";
      description = ''
        The directory where qBittorrent will store its configuration.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        qBittorrent web UI port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Allow qBittorrent's ports to accept connections from the outside network.
      '';
    };

    openFilesLimit = mkOption {
      default = 4096;
      description = ''
        Number of files to allow qBittorrent to open.
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.qbittorrent = {
      path = [ pkg ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "qBittorrent Daemon";
      serviceConfig = {
        ExecStart = ''
          ${pkg}/bin/qbittorrent-nox \
            --profile=${cfg.configDir} \
            --webui-port=${toString cfg.port}
        '';
        User = cfg.user;
        Group = cfg.group;
        UMask = "0002";
        Restart = "on-success";
        LimitNOFILE = cfg.openFilesLimit;
        StateDirectory = "qbittorrent";
      };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        isSystemUser = true;
        description = "qBittorrent Daemon user";
      };
    };

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = { };
    };
  };
}
