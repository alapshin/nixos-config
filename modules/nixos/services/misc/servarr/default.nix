{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (import ./app.nix "sonarr")
    (import ./app.nix "radarr")
    (import ./app.nix "lidarr")
    (import ./app.nix "readarr")
    (import ./app.nix "prowlarr")
  ];
}
