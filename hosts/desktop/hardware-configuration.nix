{
  lib,
  pkgs,
  config,
  ...
}:

{
  zramSwap.enable = true;

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "r8169"
        "usbhid"
        "usb_storage"
        "xhci_pci"
      ];
      luks.devices = {
        "luksroot" = {
          device = "/dev/disk/by-uuid/56cd0776-0e1a-46b2-8e61-56a1aab91c4a";
          allowDiscards = true;
        };
        "luksdata" = {
          device = "/dev/disk/by-uuid/f8c9d40f-d397-46d2-a058-55a225d2670e";
          allowDiscards = true;
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/20b4e7b3-3a81-468e-9ca9-2fdc1b6c2238";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "discard=async"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/A0D1-44CF";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/20b4e7b3-3a81-468e-9ca9-2fdc1b6c2238";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "discard=async"
      ];
    };
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/1a34979e-9d0a-47bf-a2a8-2034afddec19";
      fsType = "btrfs";
      options = [
        "subvol=data"
        "discard=async"
      ];
    };
  };
}
