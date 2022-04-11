{ config, lib, inputs, pkgs, self, ... }:

{
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nixPath = [
      "nixpkgs=${inputs.nixos}"
    ];
    registry = {
      nixos.flake = inputs.nixos;
      nixpkgs.flake = inputs.nixpkgs;
    };
  };

  nixpkgs = {
    pkgs = pkgs;
  };

  system = {
    stateVersion = "20.09";
    configurationRevision = lib.mkIf (self ? rev) self.rev;
  };

  boot = {
    # Enable the magic SysRq key
    kernel.sysctl = {
      "kernel.sysrq" = 438;
    };
    kernelModules = [ "kvm-amd" "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  console = {
    font = "latarcyrheb-sun32";
    earlySetup = true;
    useXkbConfig = true;
  };

  fonts = {
    fonts = with pkgs; [
      open-sans
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
      firacode-nerdfonts
    ];
    enableDefaultFonts = false;
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  time = {
    timeZone = "Europe/Moscow";
    hardwareClockInLocalTime = true;
  };

  security = {
    sudo = {
      extraConfig = ''
        Defaults !tty_tickets
      '';
    };
  };

  # Various nix utils
  environment.systemPackages = with pkgs; [
    nix-index
    nix-prefetch-git
    nix-prefetch-github
    nixpkgs-fmt
  ];
}
