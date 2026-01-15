{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
{
  services.podman = {
    enable = true;
    # images = {
    #   "opencode" = {
    #         image = "${opencodeContainerImage.name}";
    #   };
    # };
    machines = {
      "dev-machine" = {
        rootful = false;
        timezone = "UTC";
        volumes = [
          "/Users:/Users"
          "/private:/private"
        ];
        autoStart = true;
        watchdogInterval = 30;
      };
    };
  };
}
