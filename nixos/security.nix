{ config, pkgs, ... }:

{
  security.sudo = {
    extraConfig = ''
      Defaults !tty_tickets
    '';
  };
}
