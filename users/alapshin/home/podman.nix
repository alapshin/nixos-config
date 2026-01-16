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
    machines = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
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
