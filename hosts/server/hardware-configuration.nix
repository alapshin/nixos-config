{ config
, lib
, pkgs
, ...
}:
let 
  disk = "/dev/sda";
in
{
  boot = {
    loader = {
      grub = {
        devices = [ disk ];
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };

    initrd = {
      availableKernelModules = [ "ahci" "nvme" "usbhid" "usb_storage" "xhci_pci" ];
    };
  };

  disko.devices = import ./disk-config.nix {
    disks = [ disk ];
  };
}
