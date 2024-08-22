{
  lib,
  pkgs,
  config,
  ...
}:

{
  boot = {
    initrd = {
      luks.devices."luksroot" = {
        device = "/dev/disk/by-uuid/8119ac87-97bb-44fd-889f-79389f22588b";
        allowDiscards = true;
      };
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
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
