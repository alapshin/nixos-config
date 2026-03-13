# Boot configuration (systemd-boot) - NixOS aspect
{ ... }:
{
  flake.modules.nixos.boot =
    { lib, ... }:
    {
      boot = {
        loader = {
          timeout = 15;
          efi.canTouchEfiVariables = true;
          systemd-boot = {
            enable = lib.mkDefault true;
            consoleMode = "max";
            configurationLimit = 10;
          };
        };
      };
    };
}
