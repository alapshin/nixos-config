{ ... }:
{
  flake.modules.nixos.openssh =
    { pkgs, ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "prohibit-password";
        };
      };
    };
}
