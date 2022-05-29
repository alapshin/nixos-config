{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    # Enable the magic SysRq key
    kernel.sysctl = {
      "kernel.sysrq" = 438;
    };
    kernelModules = ["kvm-amd" "kvm-intel"];
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

  environment.systemPackages = with pkgs; [
    ntfs3g
  ];
}
