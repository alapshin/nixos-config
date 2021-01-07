{ config, pkgs, ... }:

{
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudio;
      support32Bit = true;
    };
  };
}
