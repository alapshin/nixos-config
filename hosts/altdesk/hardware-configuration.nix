{ config
, lib
, pkgs
, ...
}:
{
  boot = {
    loader = {
      timeout = 15;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 10;
      };
    };
    # Workaround for frequent wifi connection loss
    # https://bugzilla.kernel.org/show_bug.cgi?id=203709
    extraModprobeConfig = ''
      options iwlmvm power_scheme=1
      options iwlwifi power_save=0
    '';

    initrd = {
      availableKernelModules = [ "ahci" "nvme" "usbhid" "usb_storage" "xhci_pci" ];
      luks.devices."luks-9ebe5c59-eac5-47eb-b517-c82f2ede2ca3" = {
        device = "/dev/disk/by-uuid/9ebe5c59-eac5-47eb-b517-c82f2ede2ca3";
        keyFile = "/dev/sda";
        keyFileSize = 2048;
        allowDiscards = true;
      };
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/5C3B-A244";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-uuid/4a5edb30-f86b-4ec3-a493-8de48c8ee703";
      fsType = "btrfs";
      options = [ "subvol=root" "discard=async" ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/4a5edb30-f86b-4ec3-a493-8de48c8ee703";
      fsType = "btrfs";
      options = [ "subvol=home" "discard=async" ];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/c84a09e7-8889-4c45-a6f5-0a39dcdb031f";
      randomEncryption.enable = true;
    }
  ];
}
