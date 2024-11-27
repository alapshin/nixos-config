{ pkgs, config, ... }:
{
  services = {

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

    languagetool = {
      enable = true;
    };
  };
}
