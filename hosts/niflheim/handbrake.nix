{
  lib,
  pkgs,
  config,
  ...
}:
{

  users.users."makemkv" = {
    isSystemUser = true;
    group = "media";
    home = "/var/lib/makemkv";
    linger = true;
    createHome = true;
    autoSubUidGidRange = true;
  };

  # users.users."handbrake" = {
  #   isSystemUser = true;
  #   group = "media";
  #   home = "/var/lib/handbrake";
  #   linger = true;
  #   createHome = true;
  #   autoSubUidGidRange = true;
  # };
  #
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
    };
  };

  virtualisation.oci-containers = {
    containers = {
      makemkv = {
        image = "jlesage/makemkv";
        ports = [ "127.0.0.1:5800:5800" ];
        volumes = [
          "/var/lib/makemkv:/config"
          "/mnt/data/output:/output"
          "/mnt/data/downloads:/storage"
        ];
        podman.user = "makemkv";
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

  # systemd.services."${containerBackend}-handbrake-server".serviceConfig = {
  #   StateDirectory = "handbrake";
  # };
}
