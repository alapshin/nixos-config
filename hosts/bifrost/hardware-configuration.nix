{ config
, lib
, pkgs
, modulesPath
, ...
}:
{
  imports = [
    ./disk-config.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };

    initrd = {
      availableKernelModules = [ "ahci" "nvme" "usbhid" "usb_storage" "xhci_pci" ];
    };
  };
}
