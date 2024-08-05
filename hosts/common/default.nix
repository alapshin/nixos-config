{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./audio.nix
    ./backup.nix
    ./secrets.nix
    ./services.nix
    ./networking.nix
    ./graphical-desktop.nix
    ./xray-client.nix
  ];
  boot = {
    # Enable the magic SysRq key
    kernel.sysctl = {
      "kernel.sysrq" = 438;
    };
    kernelModules = [ "kvm-amd" "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_zen;
    initrd = {
      systemd = {
        enable = true;
      };
    };
  };

  console = {
    font = "latarcyrheb-sun32";
    earlySetup = true;
    useXkbConfig = true;
  };

  fonts = {
    fontconfig = {
      defaultFonts = {
        emoji = [
          "Noto Color Emoji"
        ];
        serif = [
          "IBM Plex Serif"
        ];
        sansSerif = [
          "IBM Plex Sans"
        ];
        monospace = [
          "JetBrainsMono Nerd Font Mono"
        ];
      };
    };
    enableDefaultPackages = false;
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

  time = {
    timeZone = "Europe/Moscow";
  };

  security = {
    sudo = {
      extraConfig = ''
        Defaults !tty_tickets
      '';
    };
    tpm2 = {
      enable = true;
      pkcs11.enable = false;
      tctiEnvironment.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
    ntfs3g
  ];
}
