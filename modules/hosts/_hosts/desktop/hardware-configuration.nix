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
    };
  };

  services.beesd.filesystems = {
    root = {
      spec = "LABEL=system";
      extraOptions = [
        "--thread-factor"
        "0.25"
        "--loadavg-target"
        "2"
      ];
    };
  };
}
