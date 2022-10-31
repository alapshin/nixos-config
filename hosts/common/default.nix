{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./audio.nix
    ./backup.nix
    ./secrets.nix
    ./services.nix
    ./networking.nix
  ];
  boot = {
    # Enable the magic SysRq key
    kernel.sysctl = {
      "kernel.sysrq" = 438;
    };
    kernelModules = ["kvm-amd" "kvm-intel"];
    kernelPackages = pkgs.linuxPackages_zen;
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
    supportedLocales = [
      "en_DK.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };

  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-sstp
        networkmanager-openvpn
      ];
    };
  };

  time = {
    timeZone = "Europe/Moscow";
  };

  security = {
    sudo = {
      extraConfig = ''
        Defaults !tty_tickets
      '';
    };
  };

  environment.sessionVariables = {
    GTK_USE_PORTAL = "1";
  };

  environment.systemPackages = with pkgs; [
    sstp
    ntfs3g
  ];
}
