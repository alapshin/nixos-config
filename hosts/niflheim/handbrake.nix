{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "dockerhub/password" = {
        owner = "makemkv";
      };
    };
  };

  users.groups."makemkv" = {
    gid = 970;
  };
  users.users."makemkv" = {
    uid = 970;
    group = "makemkv";
    extraGroups = [
      "media"
    ];
    home = "/var/lib/makemkv";
    createHome = true;
    isSystemUser = true;
    useDefaultShell = true;
    autoSubUidGidRange = true;
  };

  users.groups."mkvtoolnix" = {
    gid = 2001;
  };
  users.users."mkvtoolnix" = {
    uid = 2001;
    group = "mkvtoolnix";
    extraGroups = [
      "media"
    ];
    home = "/var/lib/mkvtoolnix";
    createHome = true;
    isSystemUser = true;
    useDefaultShell = true;
    autoSubUidGidRange = true;
  };

  users.groups."handbrake" = {
    gid = 971;
  };
  users.users."handbrake" = {
    uid = 971;
    group = "handbrake";
    extraGroups = [
      "media"
    ];
    home = "/var/lib/handbrake";
    createHome = true;
    isSystemUser = true;
    useDefaultShell = true;
    autoSubUidGidRange = true;
  };

  services = {
    webhost.applications = {
      "makemkv" = {
        auth = true;
        port = 5800;
      };
      # "handbrake" = {
      #   auth = true;
      #   port = 9999;
      # };
      "mkvtoolnix" = {
        auth = true;
        port = 5801;
      };
    };
  };

  virtualisation.oci-containers = {
    containers = {
      makemkv = {
        image = "docker.io/jlesage/makemkv:v25.02.3";
        ports = [ "127.0.0.1:5800:5800" ];
        volumes = [
          "/var/lib/makemkv:/config"
          "/mnt/data/output:/output"
          "/mnt/data/downloads:/storage"
        ];
      };

      mkvtoolnix = {
        image = "docker.io/jlesage/mkvtoolnix:v25.03.1";
        ports = [ "127.0.0.1:5801:5800" ];
        volumes = [
          "/mnt/data:/storage"
          "/var/lib/mkvtoolnix:/config"
        ];
        podman.user = "mkvtoolnix";
      };

      # handbrake-server = {
      #   image = "ghcr.io/thenickoftime/handbrake-web-server:0.7.3";
      #   ports = ["127.0.0.1:9999:9999"];
      #   volumes = [
      #     "/var/lib/handbrake:/data"
      #     "/mnt/data/downloads:/video"
      #   ];
      #   podman.user = "handbrake";
      # };
      # handbrake-worker = {
      #   image = "ghcr.io/thenickoftime/handbrake-web-worker:0.7.3";
      #   ports = ["127.0.0.1:10000:10000"];
      #   volumes = [
      #     "/mnt/data/downloads:/video"
      #   ];
      #   environment = {
      #     SERVER_URL = "127.0.0.1";
      #     SERVER_PORT = "9999";
      #   };
      #   podman.user = "handbrake";
      # };
    };
  };

  systemd.services."podman-makemkv".serviceConfig = {
    StateDirectory = "makemkv";
  };

  systemd.services."podman-mkvtoolnix".serviceConfig = {
    StateDirectory = "mkvtoolnix";
  };
}
