{ config, pkgs, ... }:

{
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
  };

  services.jack = {
    # support ALSA only programs via ALSA JACK PCM plugin
    alsa = {
      enable = false;
    };
    # support ALSA only programs via loopback device (supports programs like Steam)
    loopback = {
      enable = false;
    };
    jackd = {
      enable = false;
      # extraOptions = [
      #   "-v" "-dalsa" "-r48000" "-p1024" "-n2" "-D" "-Chw:Microphone" "-Phw:ODACrevB"
      # ];
    };
  };

  environment.systemPackages = with pkgs; [
    kwave
    jack2
    qjackctl
    obs-studio
    pavucontrol
  ];
}
