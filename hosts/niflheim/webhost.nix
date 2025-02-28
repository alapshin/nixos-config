{
  lib,
  pkgs,
  config,
  ...

}:
{
  services.webhost.basedomain = "bitgarage.dev";
  services.webhost.authdomain = "auth.bitgarage.dev";
}
