{
  lib,
  pkgs,
  config,
  ...
}:
{
  services = {
    avahi = {
      enable = true;
    };

    geoclue2 = {
      enable = true;
    };

    kmscon = {
      enable = true;
      hwRender = true;
      fonts = [
        {
          name = "";
          package = pkgs.nerd-fonts.jetbrains-mono;
        }
      ];
    };

    openssh = {
      enable = true;
    };
  };
}
