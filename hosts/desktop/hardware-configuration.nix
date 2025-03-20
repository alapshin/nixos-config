{
  lib,
  pkgs,
  config,
  ...
}:

{
  zramSwap.enable = true;

  imports = [
    ./disk-config.nix
  ];

  boot = {
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];
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
        "luksdata" = {
          device = "/dev/disk/by-uuid/f8c9d40f-d397-46d2-a058-55a225d2670e";
          allowDiscards = true;
        };
      };
    };
  };

  fileSystems = {
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
