{ config
, lib
, pkgs
, ...
}: {
  boot = {
    kernelModules = [ "kvm-intel" "v4l2loopback" ];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';

    loader = {
      timeout = 15;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        # Lanzaboote currently replaces the systemd-boot module.
        # This setting is usually set to true in configuration.nix
        # generated at installation time. So we force it to false
        # for now.
        enable = lib.mkForce false;
        consoleMode = "max";
        configurationLimit = 7;
      };
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    initrd = {
      luks.devices."luksroot".device = "/dev/disk/by-uuid/8119ac87-97bb-44fd-889f-79389f22588b";
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/5952-0C32";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-uuid/6d4f3850-0279-46ed-9b2c-4e5382d1d2ad";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/6d4f3850-0279-46ed-9b2c-4e5382d1d2ad";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };
  };

}

